import Foundation
#if canImport(UIKit)
import UIKit
#endif

enum Platform {
    #if canImport(UIKit)
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    static var isPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
    #else
    static var isIPad: Bool { false }
    static var isPhone: Bool { false }
    #endif
}
