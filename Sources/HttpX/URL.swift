// Copyright 2024-2024 Ruiyang Sun. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation

/// Extension to Foundation's `URL` type.
public extension URL {
    /// Checks if the URL is an absolute URL.
    var isAbsoluteURL: Bool {
        scheme != nil && host != nil
    }

    /// Checks if the URL is a relative URL.
    var isRelativeURL: Bool { !isAbsoluteURL }

    /// Merges new query items into the URL's existing query items. If an item already exists, it is updated.
    /// - Parameter newItems: The new query items to merge into the URL.
    /// - Throws: `URLError.badURL` if the URL cannot be properly constructed with the new query items.
    mutating func mergeQueryItems(_ newItems: [URLQueryItem]) throws {
        var components = URLComponents(string: absoluteString)!
        var queryItems = components.queryItems ?? []
        for item in newItems {
            if let index = queryItems.firstIndex(where: { $0.name == item.name }) {
                queryItems[index] = item
            } else {
                queryItems.append(item)
            }
        }
        components.queryItems = queryItems
        self = components.url!
    }

    private static var httpDefaultPort: Int = 80
    private static var httpsDefaultPort: Int = 443

    internal static func portOrDefault(_ url: URL) -> Int? {
        if url.port != nil {
            return url.port
        }
        return ["http": httpDefaultPort, "https": httpsDefaultPort][url.scheme ?? ""]
    }

    internal static func sameOrigin(_ url: URL, _ other: URL) -> Bool {
        url.scheme == other.scheme
            && url.host == other.host
            && URL.portOrDefault(url) == URL.portOrDefault(other)
    }

    internal static func isHttpsRedirect(_ url: URL, location: URL) -> Bool {
        if url.host != location.host {
            return false
        }

        return
            url.scheme == "http"
                && URL.portOrDefault(url) == httpDefaultPort
                && location.scheme == "https"
                && URL.portOrDefault(location) == httpsDefaultPort
    }
}
