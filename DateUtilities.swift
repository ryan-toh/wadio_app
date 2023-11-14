import SwiftUI
import Foundation

// This exists due to appstorage not supporting dates
// Converts Date to Strings, and vice versa
struct DateUtilities {
    func dateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        return dateFormatter.string(from: date)
    }
    
    func StringtoDate(date: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        return dateFormatter.date(from: date) ?? Date.now
    }
    
    func readJSONFile(fileName: String) {
         
        
//        do {  
//            
//            // creating a path from the main bundle and getting data object from the path
//            if let bundlePath = Bundle.main.path(forResource: name, ofType: "json"),
//               let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
//                
//                // Decoding the Product type from JSON data using JSONDecoder() class.
//                let product = try JSONDecoder().decode(Product.self, from: jsonData)
//                print("Product name: \(product.title) and its price: \(product.price)")
//            }
//        } catch {
//            print(error)
//        }
    }
}
