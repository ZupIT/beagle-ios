/*
 * Copyright 2020, 2022 ZUP IT SERVICOS EM TECNOLOGIA E INOVACAO SA
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

@testable import Beagle
import Foundation

enum ComponentFromJsonError: Error {
    case wrongUrlPath
}

func componentFromJsonFile<T>(
    fileName: String
) throws -> T {
    guard let url = Bundle(for: BeagleCoderTests.self).url(
        forResource: fileName,
        withExtension: ".json"
    ) else {
        throw ComponentFromJsonError.wrongUrlPath
    }

    let data = try Data(contentsOf: url)
    return try componentFromData(data)
}

func componentFromString<A: BeagleCodable>(
    _ string: String
) throws -> A {
    guard let data = string.data(using: .utf8) else {
        throw ComponentFromJsonError.wrongUrlPath
    }

    return try componentFromData(data)
}

func componentFromData<T>(
    _ data: Data,
    decoder: CoderProtocol = Coder()
) throws -> T {
    return try decoder.decode(from: data)
}

func jsonFromFile(
    fileName: String
) throws -> String {

    guard let url = Bundle(for: ScreenComponentTests.self).url(
        forResource: fileName,
        withExtension: "json"
    ) else {
        throw ComponentFromJsonError.wrongUrlPath
    }

    let jsonData = try Data(contentsOf: url)
    let json = String(bytes: jsonData, encoding: .utf8) ?? ""

    return json
}

/// This method was only created due to some problems with Swift Type Inference.
/// So when you pass the type as a parameter, swift can infer the correct type.
func componentFromJsonFile<W: BeagleCodable>(
    componentType: W.Type,
    fileName: String
) throws -> W {
    return try componentFromJsonFile(fileName: fileName)
}
