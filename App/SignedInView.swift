import SwiftUI
// wanted to test pushing in private repo 
struct SignedInView: View {
    // You can inject the ViewModel here if needed later to display user info or add a sign-out button
    // @StateObject private var viewModel = AuthenticationViewModel()

    var body: some View {
        // Simple white background as requested
        Color.white
            .ignoresSafeArea()
            .navigationTitle("Signed In") // Optional: Add a title
            .navigationBarBackButtonHidden(true) // Hide back button since we are logged in
            // Add a Sign Out button for testing/demonstration
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Sign Out") {
                        // TODO: Implement sign out functionality - will require injecting ViewModel
                        print("Sign Out tapped - Functionality to be added")
                        // viewModel.signOut()
                    }
                }
                #endif
            }
    }
}

#Preview {
    NavigationView { // Wrap in NavigationView for preview context
        SignedInView()
    }
} 