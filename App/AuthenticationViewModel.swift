import SwiftUI
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift // Required for the GoogleSignInButton

@MainActor // Ensure UI updates happen on the main thread
class AuthenticationViewModel: ObservableObject {
    @Published var isUserSignedIn = false // Tracks the user's sign-in state
    @Published var errorMessage: String? // Stores any error messages

    init() {
        // Check if the user is already signed in when the ViewModel is initialized
        checkCurrentUser()
    }

    // Check the current Firebase user status
    func checkCurrentUser() {
        isUserSignedIn = Auth.auth().currentUser != nil
    }

    // Function to initiate the Google Sign-In flow
    func signInWithGoogle() async {
        errorMessage = nil // Reset error message

        // Get the top view controller to present the Google Sign-In screen
        guard let topVC = await Utilities.topViewController() else {
            errorMessage = "Could not find top view controller."
            print("Error: Could not find top view controller.")
            return
        }

        do {
            // Start the Google Sign-In flow
            let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)

            // Get the user's ID token and access token
            guard let idToken = gidSignInResult.user.idToken?.tokenString else {
                errorMessage = "Could not get ID token from Google."
                print("Error: Could not get ID token from Google.")
                return
            }
            let accessToken = gidSignInResult.user.accessToken.tokenString

            // Create a Firebase credential using the Google tokens
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

            // Sign in to Firebase with the Google credential
            // Assign to _ to silence the unused variable warning, we only need the side effect
            _ = try await Auth.auth().signIn(with: credential)
            // We can still get the user if needed after sign-in succeeds
            if let user = Auth.auth().currentUser {
                 print("Successfully signed in with Google: User UID - \\(user.uid)")
            } else {
                 // This case should ideally not happen if signIn succeeds without error
                 print("Successfully signed in with Google, but couldn't retrieve current user immediately.")
            }
            self.isUserSignedIn = true // Update sign-in state

        } catch GIDSignInError.canceled {
             // Handle the case where the user cancels the sign-in flow
            print("Google Sign-In cancelled by user.")
            // No need to show an error message here, it's expected user behavior.
        }
        catch {
            // Handle other potential errors during sign-in
            errorMessage = "Failed to sign in with Google: \\(error.localizedDescription)"
            print("Error signing in with Google: \\(error.localizedDescription)")
            self.isUserSignedIn = false // Ensure state reflects failure
        }
    }

    // Function to sign the user out
    func signOut() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut() // Sign out from Google as well
            self.isUserSignedIn = false
            print("Successfully signed out.")
        } catch let signOutError as NSError {
            errorMessage = "Error signing out: \\(signOutError.localizedDescription)"
            print("Error signing out: %@", signOutError)
        }
    }
}


// Helper struct to find the top view controller
struct Utilities {
    // The @MainActor attribute ensures this runs on the main thread
    @MainActor static func topViewController(controller: UIViewController? = nil) async -> UIViewController? {
        // Updated approach to get the key window scene's root view controller
        let scenes = await UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        // Use nonisolated to access window properties off the main actor if needed,
        // but generally UI properties should be accessed on main thread.
        // Check if windowScene is nil before proceeding.
        guard let windowScene = windowScene else { return nil }
        let keyWindow = await windowScene.windows.first { $0.isKeyWindow }
        let rootViewController = await keyWindow?.rootViewController

        // Use the provided controller or the determined rootViewController
        let currentController = controller ?? rootViewController

        // If the current controller is a navigation controller, recurse with its visible view controller.
        if let navigationController = currentController as? UINavigationController,
           let visibleController = navigationController.visibleViewController {
            // Recursive call is already covered by @MainActor on the function
            return await topViewController(controller: visibleController)
        }
        // If the current controller is a tab bar controller, recurse with its selected view controller.
        if let tabController = currentController as? UITabBarController,
           let selected = tabController.selectedViewController {
             // Recursive call is already covered by @MainActor on the function
            return await topViewController(controller: selected)
        }
        // If the current controller has a presented view controller, recurse with it.
        if let presented = await currentController?.presentedViewController {
            // Recursive call is already covered by @MainActor on the function
            return await topViewController(controller: presented)
        }
        // If none of the above, return the current controller.
        return currentController
    }
} 