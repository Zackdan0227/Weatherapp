//
//  svgMapping.swift
//  weatherapp
//
//  Created by Kedan Zha on 8/28/24.
//

import Foundation

func svgName(for weatherCode: Int) -> String {
    switch weatherCode {
    case 0:
        return "clear-day"
    case 1, 2, 3:
        return "partly-cloudy-day" // or "overcast" based on your asset names
    case 45, 48:
        return "fog"
    case 51, 53, 55:
        return "drizzle"
    case 56, 57:
        return "freezing-drizzle"
    case 61, 63, 65:
        return "rain"
    case 66, 67:
        return "freezing-rain"
    case 71, 73, 75:
        return "snow"
    case 77:
        return "snow-grains"
    case 80, 81, 82:
        return "rain-showers"
    case 85, 86:
        return "snow-showers"
    case 95:
        return "thunderstorm"
    case 96, 99:
        return "thunderstorm-hail"
    default:
        return "clear-day" // Default icon if no match found
    }
}

