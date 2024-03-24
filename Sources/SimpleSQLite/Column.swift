import Foundation

/// Column type protocol. Usually used to implement an enum describing the available columns.
///
/// Example:
/// ```
/// enum AnimalColumns: String, SQLiteColumn {
/// 	case id
/// 	case name
/// 	case age = "animalAge"
/// }
/// ```
public protocol Column {
	var name: String { get }
}

public extension Column where Self: RawRepresentable, RawValue == String {
	var name: String {
		rawValue
	}
}
