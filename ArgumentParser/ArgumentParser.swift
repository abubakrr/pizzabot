//
//  ArgumentParser.swift
//  ArgumentParser
//
//  Created by Abu-Bakr Jabbarov on 12/22/21.
//

import Foundation
import Instructor

public final class ArgumentParser {

    public static func parse( _ arguments: [String]) throws -> (map: Map, locations: [Location]) {
        let filteredArguments = ArgumentParser.filterEmptyArguments(arguments)
        guard filteredArguments.count >= 2 else {
            throw ParseError.invalidArguments
        }
        
        let mapSizeArgument = filteredArguments[0]
        let locationCoordinateArguments = Array(filteredArguments.dropFirst())
        
        let map = try ArgumentParser.parseMapSize(mapSizeArgument)
        let locations = try locationCoordinateArguments
            .map { try ArgumentParser.parseLocation($0) }
        
        return (map, locations)
    }
    
    static func parseMapSize( _ argument: String) throws -> Map {
        guard ArgumentParser.validateMapSizeArgument(argument) else {
            throw ParseError.invalidMapSizeArgument
        }
        
        let arguments = argument.replacingOccurrences(of: "X", with: "x").split(separator: "x")
        let width = Int(arguments[0])!
        let height = Int(arguments[1])!
        return Map(width: width, height: height)
    }
    
    static func parseLocation( _ argument: String) throws -> Location {
        guard ArgumentParser.validateLocationArgument(argument) else {
            throw ParseError.invalidLocationCoordinateArgument
        }
        
        let arguments = argument.filter("0123456789,".contains).split(separator: ",")
        let x = Int(arguments[0])!
        let y = Int(arguments[1])!
        return Location(x: x, y: y)
    }
    
    static func validateMapSizeArgument( _ argument: String) -> Bool {
        // ^[1-9](\\d*) - Map size argument should start with non zero integer
        // (x|X) - followed by x or X character
        // [1-9](\\d*)$ - Finally it should end with non zero integer
        let regex: String = "^[1-9](\\d*)" + "(x|X)" + "[1-9](\\d*)$"
        let isValid = argument.range(of: regex, options: .regularExpression) != nil
        return isValid
    }
    
    static func validateLocationArgument( _ argument: String) -> Bool {
        // ^\\( - Argument should start with an opening prefix
        // \\d+) - followed by a positive digit
        // (,|.) - followed by a comma or a dot
        // (\\d+) - followed by a positive digit
        // \\)$ - finally ended with a closing parenthesis
        let regex: String = "^\\(" + "(\\d+)" + "(,|.)" + "(\\d+)" + "\\)$"
        let isValid = argument.range(of: regex, options: .regularExpression) != nil
        return isValid
    }
    
    static func filterEmptyArguments( _ arguments: [String]) -> [String] {
        return arguments.filter { !($0.replacingOccurrences(of: "\n", with: " ").trimmingCharacters(in: .whitespaces)).isEmpty }
    }
}
