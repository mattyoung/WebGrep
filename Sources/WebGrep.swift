// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import OSLog
import ArgumentParser
import SwiftSoup
//import ANSITerminal   // https://github.com/pakLebah/ANSITerminal
import Rainbow          // https://github.com/onevcat/Rainbow.git
import Spinner


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
    commandName: "webgrep",
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

    @Option(name: .shortAndLong, help: "Enter a output file name, default is \"font(ostype).txt\".")
    var output: String? = nil

    mutating func run() throws {
      // just hardcode and force unwrap, will crash if this is wrong
      let url = URL(string: Self.urlString)!

      let spinner = Spinner([.dots, .dots8Bit].randomElement()!, "Downloading...", color: .cyan)

      if options.verbose {
        spinner.start()
      }

      do {
        let doc = try SwiftSoup.parse(try String(contentsOf: url))
        // find all fonts, each is inside css class "font-item"
        if options.verbose {
          spinner.updateText("Processing the DOM")
        }
        let fontNames = try doc.getElementsByClass("font-item")
          .filter { try isBuiltIn($0, contains: ostype.rawValue) }
          .map { try $0.getElementsByClass("filter-font-name").text() }

        let codeString = codeGen(fontNames)
        if let output {
          if options.verbose {
            spinner.updateText("Saving result to \(output)")
          }
          try codeString.write(toFile: output, atomically: true, encoding: .utf8)
        } else {
          print(codeString)
        }

        if options.verbose {
          spinner.succeed("Done \(Date.now)")
        }
      } catch {
        if options.verbose {
          spinner.failure("Something went wrong: \(error).")
        }
        throw error
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

    func codeGen(_ fontNames: [String]) -> String {
      var result = String()
      result.append("// Generated: For \(ostype.rawValue) on \(Date.now), \(fontNames.count) fonts\n")
      result.append("// Extracted from \(Self.urlString)\n")
      for name in fontNames {
        result.append("case \(name.asIdentifier.lowercasedFirstLetter()) = \"\(name)\"\n")
      }
      result.append("// Generated: For \(ostype.rawValue) on \(Date.now), \(fontNames.count) fonts\n")
      result.append("// Extracted from \(Self.urlString)\n")

      return result
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
