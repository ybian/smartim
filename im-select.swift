//
//  InputSourceManager.swift
//  kawa
//
//  Created by utatti on 27/07/2015.
//  Copyright (c) 2015-2017 utatti and project contributors.
//  Licensed under the MIT License.
//

import Carbon
import Cocoa
import Foundation

extension TISInputSource {
    enum Category {
        static var keyboardInputSource: String {
            return kTISCategoryKeyboardInputSource as String
        }
    }

    private func getProperty(_ key: CFString) -> AnyObject? {
        let cfType = TISGetInputSourceProperty(self, key)
        if (cfType != nil) {
            return Unmanaged<AnyObject>.fromOpaque(cfType!).takeUnretainedValue()
        } else {
            return nil
        }
    }

    var id: String {
        return getProperty(kTISPropertyInputSourceID) as! String
    }

    var name: String {
        return getProperty(kTISPropertyLocalizedName) as! String
    }

    var category: String {
        return getProperty(kTISPropertyInputSourceCategory) as! String
    }

    var isSelectable: Bool {
        return getProperty(kTISPropertyInputSourceIsSelectCapable) as! Bool
    }

    var sourceLanguages: [String] {
        return getProperty(kTISPropertyInputSourceLanguages) as! [String]
    }
}

class InputSource: Equatable {
    static func == (lhs: InputSource, rhs: InputSource) -> Bool {
        return lhs.id == rhs.id
    }

    let tisInputSource: TISInputSource

    var id: String {
        return tisInputSource.id
    }

    var name: String {
        return tisInputSource.name
    }

    var isCJKV: Bool {
        if let lang = tisInputSource.sourceLanguages.first {
            return lang == "ko" || lang == "ja" || lang == "vi" || lang.hasPrefix("zh")
        }
        return false
    }

    init(tisInputSource: TISInputSource) {
        self.tisInputSource = tisInputSource
    }

    func select() {
        TISSelectInputSource(tisInputSource)

        if isCJKV, let selectPreviousShortcut = InputSourceManager.getSelectPreviousShortcut() {
            // Workaround for TIS CJKV layout bug:
            // when it's CJKV, select nonCJKV input first and then return
            if let nonCJKV = InputSourceManager.nonCJKVSource() {
                nonCJKV.select()
                InputSourceManager.selectPrevious(shortcut: selectPreviousShortcut)
            }
        }
    }
}

class InputSourceManager {
    static var inputSources: [InputSource] = []

    static func initialize() {
        let inputSourceNSArray = TISCreateInputSourceList(nil, false).takeRetainedValue() as NSArray
        let inputSourceList = inputSourceNSArray as! [TISInputSource]

        inputSources = inputSourceList.filter({
            $0.category == TISInputSource.Category.keyboardInputSource && $0.isSelectable
        }).map { InputSource(tisInputSource: $0) }
    }

    static func nonCJKVSource() -> InputSource? {
        return inputSources.first(where: { !$0.isCJKV })
    }

    static func selectPrevious(shortcut: (Int, UInt64)) {
        let src = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)!

        let rawKey = shortcut.0
        let rawFlags = shortcut.1

        let down = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(rawKey), keyDown: true)!
        let up = CGEvent(keyboardEventSource: src, virtualKey: CGKeyCode(rawKey), keyDown: false)!

        let flag = CGEventFlags(rawValue: rawFlags)
        down.flags = flag;
        up.flags = flag;

        let loc = CGEventTapLocation.cghidEventTap

        down.post(tap: loc)
        up.post(tap: loc)
    }

    // from read-symbolichotkeys script of Karabiner
    // github.com/tekezo/Karabiner/blob/master/src/util/read-symbolichotkeys/read-symbolichotkeys/main.m
    static func getSelectPreviousShortcut() -> (Int, UInt64)? {
        guard let dict = UserDefaults.standard.persistentDomain(forName: "com.apple.symbolichotkeys") else {
            return nil
        }
        guard let symbolichotkeys = dict["AppleSymbolicHotKeys"] as! NSDictionary? else {
            return nil
        }
        guard let symbolichotkey = symbolichotkeys["60"] as! NSDictionary? else {
            return nil
        }
        if (symbolichotkey["enabled"] as! NSNumber).intValue != 1 {
            return nil
        }
        guard let value = symbolichotkey["value"] as! NSDictionary? else {
            return nil
        }
        guard let parameters = value["parameters"] as! NSArray? else {
            return nil
        }
        return (
            (parameters[1] as! NSNumber).intValue,
            (parameters[2] as! NSNumber).uint64Value
        )
    }
}

let argv = CommandLine.arguments

func selectByID(id: String) {
    if InputSourceManager.inputSources.count <= 0 {
        InputSourceManager.initialize()
    }

    for input in InputSourceManager.inputSources {
        /* print(input.id) */
        if input.id == id {
            input.select()
            return
        }
    }
}

if argv.count >= 2 {
    selectByID(id: argv[1])
} else {
    let current = TISCopyCurrentKeyboardInputSource()
    let input = current!.takeUnretainedValue()
    print(input.id)
}
