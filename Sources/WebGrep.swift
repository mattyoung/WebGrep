// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import SwiftSoup
//import ANSITerminal   // https://github.com/pakLebah/ANSITerminal
import Rainbow          // https://github.com/onevcat/Rainbow.git
import OSLog

extension Logger {
  private static var subsystem = "WebGrep"

  static let status = Logger(subsystem: subsystem, category: "viewcycle")
  static let debug = Logger(subsystem: subsystem, category: "statistics")
}


enum OSType: String, ExpressibleByArgument {
  case ios = "iOS system font", macos = "macOS system font"

  init?(argument: String) {
    switch argument {
    case "ios":
      self = .ios
    case "macos":
      self = .macos
    default:
      return nil
    }
  }
}



@main
struct WebGrepApp: ParsableCommand {
  static var configuration = CommandConfiguration(
    abstract: "A utility for extracting stuff from the web.",
    subcommands: [AppleSystemFonts.self],
    defaultSubcommand: AppleSystemFonts.self
  )

  struct Options: ParsableArguments {
    @Flag(name: .shortAndLong, help: "Print status updates while running.")
    var verbose = false
  }

  mutating func run() throws {
    print("Hello, World!")
  }
}


extension WebGrepApp {


  struct AppleSystemFonts: ParsableCommand {
    static let urlString = "https://developer.apple.com/fonts/system-fonts/"
    static var configuration
    = CommandConfiguration(
      commandName: "applesystemfonts",
      abstract: "Extract system fonts from \(Self.urlString)."
    )

    @OptionGroup var options: WebGrepApp.Options

    @Argument(help: "Enter either ios or macos")
    var ostype: OSType

    mutating func run() throws {
      // just hardcode this and force unwrap, will crash if this is wrong
      if options.verbose {
        print("Visiting \(Self.urlString)".onCyan)
      }
      let url = URL(string: Self.urlString)!

      if options.verbose {
        print("Parse...".onCyan)
      }
      let doc = try SwiftSoup.parse(try String(contentsOf: url))

      if options.verbose {
        print("Processing...".onCyan)
      }

      // find all fonts, each is inside css class "font-item"
      let fontNames = try doc.getElementsByClass("font-item")
        .filter { try isBuiltIn($0, contains: ostype.rawValue) }
        .map { try $0.getElementsByClass("filter-font-name").text() }

      codeGen(fontNames)

      Logger.debug.info("Done: \(Date.now)")
      if options.verbose {
        print("Done: \(Date.now)".onCyan)
      }
    }


    /// Test to see if this `font-item` element is iOS built-in font
    /// by checking if the `font-platform` element's text() contain
    /// the string "iOS system font"
    /// - Parameter row: a row with class name `font-item`
    /// - Returns: true if this row is iOS system font
    func isBuiltIn(_ row: SwiftSoup.Element, contains key: String) throws -> Bool {
      return try row.getElementsByClass("font-platform").text().contains(key)
    }

    func codeGen(_ fontNames: [String]) {
      print("// Generated: For \(ostype.rawValue) on \(Date.now), \(fontNames.count) fonts")
      print("// Extracted from \(Self.urlString)")
      for name in fontNames {
        print("case \(name.asIdentifier.lowercasedFirstLetter()) = \"\(name)\"")
      }
      print("// Generated: For \(ostype.rawValue) on \(Date.now), \(fontNames.count) fonts")
      print("// Extracted from \(Self.urlString)")
    }
  }
}



extension String {
  var asIdentifier: String {
    String(self.filter { !$0.isWhitespace && !$0.isPunctuation && !$0.isMathSymbol })
  }

  func lowercasedFirstLetter() -> String {
    prefix(1).lowercased() + dropFirst()
  }

  mutating func lowercaseFirstLetter() {
    self = self.lowercasedFirstLetter()
  }


  func capitalizingFirstLetter() -> String {
    return prefix(1).capitalized + dropFirst()
  }

  mutating func capitalizeFirstLetter() {
    self = self.capitalizingFirstLetter()
  }

}
