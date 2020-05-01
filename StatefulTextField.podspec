Pod::Spec.new do |spec|
  spec.name = "StatefulTextField"
  spec.version = "1.0.0"
  spec.summary = "A UITextField subclass with built in live validation and formatting."
  # spec.homepage = "https://github.com/JimJoyce/StatefulTextField"
  spec.license = { type: 'MIT', file: 'LICENSE' }
  spec.authors = { "Jim Joyce" => 'jjoyce1@me.com' }
  # spec.social_media_url = "http://twitter.com/thoughtbot"

  spec.platform = :ios, "10.0"
  spec.requires_arc = true
  spec.source = { git: "https://github.com/JimJoyce/StatefulTextField.git", tag: "v#{spec.version}", submodules: true }
  spec.source_files = "StatefulTextField/**/*.{h,swift}"

end