//
//  PersonalInfoScreen.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 30/05/2025.
//

import SwiftUI
import Combine
import PhotosUI

// MARK: - API Models
struct UpdateProfileRequest: Codable {
    let name: String
    let email: String
    let avatar: String
}

struct UpdateProfileResponse: Codable {
    let data: User
}

// MARK: - API Constants Extension
extension APIConstants.Endpoints {
    static let updateMainProfile = "profile/update-profile"
}

// MARK: - NetworkService Extension for Update Profile
extension NetworkService {
    func updateProfile(name: String, email: String, avatar: String, completion: @escaping (Result<User, Error>) -> Void) {
        let endpoint = APIConstants.Endpoints.updateMainProfile
        let parameters: [String: Any] = [
            "name": name,
            "email": email,
            "avatar": avatar
        ]
        
        NetworkManager.shared.post<UpdateProfileResponse>(
            endpoint: endpoint,
            parameters: parameters,
            requiresAuth: true
        ) { (result: Result<UpdateProfileResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// MARK: - AuthService Extension for Update Profile
extension AuthService {
    func updateProfile(name: String, email: String, avatar: String) -> AnyPublisher<User, APIError> {
        return Future<User, APIError> { promise in
            NetworkService.shared.updateProfile(name: name, email: email, avatar: avatar) { result in
                switch result {
                case .success(let user):
                    // Update local user data
                    UserManager.shared.saveUser(user)
                    promise(.success(user))
                case .failure(let error):
                    let apiError = APIError.mapError(error)
                    promise(.failure(apiError))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Personal Info ViewModel
class PersonalInfoViewModel: ObservableObject {
    @Published var userName: String = ""
    @Published var email: String = ""
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var showSuccessAlert: Bool = false
    @Published var successMessage: String = ""
    @Published var selectedImage: UIImage?
    @Published var showImagePicker = false
    
    private var cancellables = Set<AnyCancellable>()
    private var base64Avatar: String = ""
    
    init() {
        loadUserData()
    }
    
    func loadUserData() {
        // Load user data from UserManager
        userName = UserManager.shared.userName ?? ""
        email = UserManager.shared.userEmail ?? ""
    }
    
    func saveChanges() {
        guard validateInputs() else { return }
        
        isLoading = true
        
        AuthService.shared.updateProfile(
            name: userName.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            avatar: base64Avatar
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                }
            },
            receiveValue: { [weak self] user in
                guard let self = self else { return }
                
                self.successMessage = "Profile updated successfully"
                self.showSuccessAlert = true
            }
        )
        .store(in: &cancellables)
    }
    
    func handleImageSelection(_ image: UIImage) {
        selectedImage = image
        
        // Convert image to base64
        if let imageData = image.jpegData(compressionQuality: 0.7) {
            base64Avatar = imageData.base64EncodedString()
        }
    }
    
    private func validateInputs() -> Bool {
        guard !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showErrorMessage("Please enter your name")
            return false
        }
        
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showErrorMessage("Please enter your email")
            return false
        }
        
        guard email.isValidEmail else {
            showErrorMessage("Please enter a valid email address")
            return false
        }
        
        return true
    }
    
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
}

// MARK: - Personal Info Screen
struct PersonalInfoScreen: View {
    @StateObject private var viewModel = PersonalInfoViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Profile Image Section
                    ProfileImageSection(viewModel: viewModel)
                    
                    // Form Fields
                    VStack(spacing: 24) {
                        // User Name Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("User Name")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary900)
                            
                            CustomTextField(
                                text: $viewModel.userName,
                                placeholder: "Enter your name",
                                keyboardType: .default
                            )
                        }
                        
                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary900)
                            
                            CustomTextField(
                                text: $viewModel.email,
                                placeholder: "Enter your email",
                                keyboardType: .emailAddress
                            )
                        }
                    }
                    
                    Spacer(minLength: 80)
                }
                .padding(.horizontal, 16)
                .padding(.top, 24)
            }
            
            // Bottom Save Button
            VStack {
                Spacer()
                
                Button(action: {
                    viewModel.saveChanges()
                }) {
                    LRButton(title: "Save changes", isPrimary: true)
                }
                .disabled(viewModel.isLoading)
                .padding(.horizontal, 16)
                .padding(.bottom, 34)
            }
            
            // Loading Overlay
            if viewModel.isLoading {
                LoadingView()
            }
        }
        .navigationTitle("Personal Info")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .alert("Success", isPresented: $viewModel.showSuccessAlert) {
            Button("OK") {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text(viewModel.successMessage)
        }
        .sheet(isPresented: $viewModel.showImagePicker) {
            ProfileImagePicker(selectedImage: $viewModel.selectedImage) { image in
                viewModel.handleImageSelection(image)
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
}

// MARK: - Profile Image Section
struct ProfileImageSection: View {
    @ObservedObject var viewModel: PersonalInfoViewModel
    
    var body: some View {
        ZStack {
            // Profile Avatar
            ZStack {
                if let selectedImage = viewModel.selectedImage {
                    // Show selected image
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                } else {
                    // Avatar Image (using your original image name)
                    Image("image")
                        .font(.system(size: 80))
                        .foregroundColor(.orange)
                }
            }
            
            // Edit Icon
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    
                    Button(action: {
                        viewModel.showImagePicker = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.primary900)
                                .frame(width: 32, height: 32)
                            
                            Image("pencil")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                    .offset(x: -8, y: -8)
                }
            }
            .frame(width: 120, height: 120)
        }
    }
}

// MARK: - Custom Text Field (Reusable Component)
struct CustomTextField: View {
    @Binding var text: String
    let placeholder: String
    let keyboardType: UIKeyboardType
    
    var body: some View {
        TextField(placeholder, text: $text)
            .font(.system(size: 16))
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            )
            .keyboardType(keyboardType)
            .autocapitalization(.none)
            .disableAutocorrection(true)
    }
}

// MARK: - Image Picker
struct ProfileImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    let onImageSelected: (UIImage) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ProfileImagePicker
        
        init(_ parent: ProfileImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
                parent.onImageSelected(editedImage)
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
                parent.onImageSelected(originalImage)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Preview
struct PersonalInfoScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PersonalInfoScreen()
        }
    }
}
