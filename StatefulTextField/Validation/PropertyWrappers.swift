import Foundation
class NoNamespaceCollision {
    
    
   enum TextFormatter: String {
     case phone = "(###) ###-####"
     case dob = "##/##/####"
     case creditCard = "#### #### #### ####"
     case none = ""
     
     var replacementChar: String {
       return "#"
     }
     
     var invalidCharacters: String {
       switch self {
         case .phone, .dob, .creditCard:
           return "[^0-9]"
         default:
           return ""
       }
     }
     
     
     func cleanedString(_ str: String) -> String {
       return str.replacingOccurrences(of: invalidCharacters,
                                                   with: "",
                                                   options: .regularExpression,
                                                   range: str.startIndex..<str.endIndex)
     }
     
     
     func format(_ string: String) -> String {
       guard self != .none else { return string }
       
       var string = cleanedString(string)
       let maskPattern = rawValue
       let final = maskPattern.reduce(into: "") { (result, char) in
         guard !string.isEmpty else {
           result.append(char == self.replacementChar.first! ? " " : char)
           return
         }
         guard char == self.replacementChar.first! else {
           result.append(char)
           return
         }

         result.append(string.removeFirst())
       }

       return final
     }
     
   }

   @propertyWrapper
   struct UseFormat {
       private var formatter: TextFormatter = .none
       private var internalValue: String = ""
       
       var projectedValue: Self { return self }
       var wrappedValue: String {
           get { return internalValue }
           set { self.internalValue = formatter.format(newValue) }
       }
       
       var unformatted: String {
           return formatter.cleanedString(wrappedValue)
       }
       
       init(wrappedValue: String) {
           self.wrappedValue = wrappedValue
       }
       
       init(wrappedValue: String, _ formatter: TextFormatter) {
           self.formatter = formatter
           self.wrappedValue = wrappedValue
       }
   }

   struct Testing {
       @UseFormat(.creditCard) var cc = "12345678912345"
       @UseFormat(.phone) var phoneNumber = "12"
   }

//   var test = Testing()
//   print(test.phoneNumber)
//   test.phoneNumber = "1234567890"
//   print(test.phoneNumber)
//   print(test.$phoneNumber.unformatted)
//   print(test.phoneNumber)




   enum Validator {
       case email, min(Int), max(Int), password
       
       func run() -> Bool {
           return true
       }
   }

   @propertyWrapper
   struct ValidatedValue<T> {
       private var validators: [Validator] = []
       private var value: T
       var projectedValue: ValidatedValue {
           return self
       }
       
       var wrappedValue: T {
           get { return self.value }
           set {
               self.value = newValue
           }
       }
       
       var isValid: Bool {
           return !validators.map { $0.run() }.contains(false)
       }
       
       init(wrappedValue: T) {
           self.value = wrappedValue
       }
       
       init(wrappedValue: T, validations: [Validator]) {
           self.value = wrappedValue
           self.validators = validations
       }
       
   }

   struct Form {
       @ValidatedValue var email: String = "asdf@asdf.com"
       @ValidatedValue(validations: [.email]) var pw = 1
   }


   @propertyWrapper
   class Bindable<T> {
       typealias DidChangeBlock = (_ newValue: T) -> Void
       private var subscribers: [DidChangeBlock] = []
       private var internalValue: T
       var wrappedValue: T {
           get {
             return internalValue
           }
           set {
               internalValue = newValue
               subscribers.forEach { $0(newValue) }
           }
       }
       
       var projectedValue: Bindable {
           return self
       }
       
       init(wrappedValue: T) {
           self.internalValue = wrappedValue
       }
       
       func onChange(_ callback: @escaping DidChangeBlock) -> Bindable {
           subscribers.append(callback)
           return self
       }
       
   }

   struct Test {
       @Bindable var myChangingString = "Hello"
       init() {
           $myChangingString.onChange { (newValue) in
               print(newValue)
           }
       }

   //
   //
   //var thing = Test()
   //
   //thing.$myChangingString.onChange { (new) in
   //    var isNew = new
   //    print("Got new value: \(isNew)")
   //}
   //
   //thing.myChangingString = "New string!"
   //thing.myChangingString = "Old string!"
   }





}

struct ImageObject {
    var urlString: String?
    func thing() {
        getUrl(for: \.urlString)
    }
    private func getUrl<Value>(for keyPath: KeyPath<ImageObject, Value>) -> URL? {
        var urlString = self[keyPath: keyPath] as? String
        urlString = urlString?.replacingOccurrences(of: "%%", with: "%25%25")
        guard let urlString = urlString, let finalURL = URL(string: urlString)
        else { return nil }
        return finalURL
    }
}
