////
////  BooksViewModel.swift
////  LexiRead
////
////  Created by Abd Elrahman Atallah on 03/03/2025.
////
//
//import Foundation
//import Alamofire
//
//struct Book: Identifiable, Decodable {
//    var id = UUID()
//    let title: String
//    let author: String
//    let coverURL: String
//    
//    enum CodingKeys: String, CodingKey {
//        case title, author
//        case coverURL = "cover_url"
//    }
//}
//
//struct PDFFile: Identifiable, Decodable {
//    var id = UUID()
//    let filename: String
//    let fileURL: String
//    
//    enum CodingKeys: String, CodingKey {
//        case filename
//        case fileURL = "file_url"
//    }
//}
//
//class BooksViewModel: ObservableObject {
//    @Published var books: [Book] = []
//    @Published var pdfFiles: [PDFFile] = []
//    @Published var isLoading = false
//    @Published var errorMessage: String?
//    
//    private let booksURL = "https://api.example.com/books"
//    private let pdfFilesURL = "https://api.example.com/pdfs"
//    
//    func fetchBooks() {
//        isLoading = true
//        
//        AF.request(booksURL).responseDecodable(of: [Book].self) { [weak self] response in
//            self?.isLoading = false
//            
////            switch response.result {
////            case .success(let books):
////                self?.books = books
////            case .failure(let error):
////                self?.errorMessage = "Failed to load books: \(error.localizedDescription)"
//                
//                // For demo purposes, populate with sample data
//                self?.books = [
//                    Book(title: "To Kill a Mockingbird", author: "Guy Hawkins", coverURL: "one-bullet-away"),
//                    Book(title: "The Little Prince", author: "Guy Hawkins", coverURL: "undomestic-goddess"),
//                    Book(title: "A Game of Thrones", author: "Guy Hawkins", coverURL: "hooked"),
//                    Book(title: "Candide", author: "Guy Hawkins", coverURL: "factfulness")
//                ]
////            }
//        }
//    }
//    
//    func fetchPDFFiles() {
//        isLoading = true
//        
//        AF.request(pdfFilesURL).responseDecodable(of: [PDFFile].self) { [weak self] response in
//            self?.isLoading = false
//            
////            switch response.result {
////            case .success(let files):
////                self?.pdfFiles = files
////            case .failure(let error):
////                self?.errorMessage = "Failed to load PDF files: \(error.localizedDescription)"
////                
//                // For demo purposes, populate with sample data
//                self?.pdfFiles = [
//                    PDFFile(filename: "S1.pdf", fileURL: "s1-url"),
//                    PDFFile(filename: "S2.pdf", fileURL: "s2-url"),
//                    PDFFile(filename: "A Game of Thrones", fileURL: "got-url"),
//                    PDFFile(filename: "Candide", fileURL: "candide-url")
//                ]
////            }
//        }
//    }
//    
//    func uploadFile(url: URL) {
//        // Implementation for file upload using Alamofire
//        // This would typically involve multipart form data upload
//        print("Uploading file from: \(url)")
//        
//        // Mock successful upload for demo
//        let filename = url.lastPathComponent
//        let newFile = PDFFile(filename: filename, fileURL: "uploaded-url")
//        pdfFiles.append(newFile)
//    }
//}
//
