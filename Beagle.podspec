#
# Copyright 2020 ZUP IT SERVICOS EM TECNOLOGIA E INOVACAO SA
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

Pod::Spec.new do |spec|

# ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.name = "Beagle"

  spec.version = '2.1.3'

  spec.summary = "A framework to help implement Server-Driven UI in your apps natively."
  spec.description = <<-DESC
    Beagle is an open source framework for cross-platform development using the 
    concept of Server-Driven UI.
  DESC
  spec.homepage = "https://docs.usebeagle.io"

# ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.license = "Apache License 2.0"

# ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.author = "Zup IT"

# ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.platform = :ios, "10.0"
  spec.swift_version = "5.0"

# ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  tag = spec.version.to_s
  source = { :git => "https://github.com/ZupIT/beagle-ios.git", :tag => tag }
  spec.source = source

# ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.default_subspec = "Beagle"

  # ――― Beagle UI ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  
  spec.subspec 'Beagle' do |beagle|
    path_source = 'Sources/Beagle/Sources'
    path_generated = 'Sources/Beagle/CodeGeneration/'

    beagle.source_files = [
      path_source + '/**/*.swift',
      path_generated + "Generated/*.generated.swift",
      path_generated + "*.swift"
    ]

    beagle.resources = [
      "**/*.xcdatamodeld",
      path_generated + "Templates/*"
    ]

    # We need this because we fixed an issue in the original repository and our PR was not merged yet.
    beagle.frameworks = 'Foundation'
    beagle.dependency 'BeagleYogaKit'
  end

  # ――― Beagle Preview ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.subspec 'Preview' do |preview|
    source = 'Sources/Preview/Sources'
    preview.source_files = source + '/**/*.swift'
    preview.dependency 'Starscream'
    preview.dependency 'Beagle/Beagle'
  end

end
