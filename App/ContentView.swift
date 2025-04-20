//
//  ContentView.swift
//  App
//
//  Created by Christopher on 4/17/25.
//

import SwiftUI

// Define UIRectCorner enum for SwiftUI
enum RectCorner {
    case topLeft, topRight, bottomLeft, bottomRight, allCorners
    
    static let all: Set<RectCorner> = [.topLeft, .topRight, .bottomLeft, .bottomRight]
}

struct ContentView: View {
    // Access the shared ViewModel from the environment
    @EnvironmentObject var authViewModel: AuthenticationViewModel

    var body: some View {
        // NavigationView provides the navigation context
        NavigationView {
            // Conditionally display view based on sign-in state
            if authViewModel.isUserSignedIn {
                // User is signed in - show the main signed-in view
                SignedInView()
            } else {
                // User is not signed in - show the onboarding/initial view
                OnboardingView()
            }
        }
        // Apply the environment object modifier here if you hadn't done it in the App struct,
        // but since we did it in FaithDateApp, this isn't strictly needed again.
        // .environmentObject(authViewModel) 
    }
}

// Extracted the original onboarding content into its own view struct
struct OnboardingView: View {
    var body: some View {
        ZStack {
            // Background color for entire screen
            Color.blue.opacity(0.1)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Top part with logo and image
                VStack(spacing: 20) {
                    Text("FaithDate")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 60)
                    
                    // Simple circle with one main image - as requested
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.3))
                            .frame(width: 280, height: 280)
                        
                        // Using the image from App/images folder
                        Image("chilling")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 240, height: 240)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 4)
                            )
                        
                        // Category Pills positioned around the circle
                        VStack {
                            HStack {
                                Spacer()
                                CategoryPill(text: "Friends", icon: "heart.fill", color: .yellow)
                                    .offset(x: -20, y: -80)
                            }
                            
                            HStack {
                                CategoryPill(text: "Relationship", icon: "heart.fill", color: .red)
                                    .offset(x: 0, y: -20)
                                Spacer()
                            }
                            
                            HStack {
                                Spacer()
                                CategoryPill(text: "Short-term Fun", icon: "star.fill", color: .orange)
                                    .offset(x: -10, y: 20)
                            }
                            
                            HStack {
                                CategoryPill(text: "Chats", icon: "bubble.left.fill", color: .white)
                                    .offset(x: 40, y: 60)
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
                
                // Bottom part with text and button - full width container
                VStack(spacing: 25) {
                    Spacer()
                    
                    VStack(spacing: 10) {
                        Text("Your ideal match, Your")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("ideal relationship.")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    Text("Create a unique emotional story that describes better than words")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // NavigationLink now goes to LoginView
                    NavigationLink(destination: LoginView()) {
                        HStack {
                            Text("Get Started")
                                .fontWeight(.semibold)
                            
                            Image(systemName: "chevron.right")
                                .font(.footnote)
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.yellow)
                        .cornerRadius(30)
                        .padding(.horizontal, 40)
                    }
                    
                    Spacer()
                    // Add extra spacer to push content up
                    Spacer()
                }
                .padding(.top, 40)
                .background(Color.white)
                .clipShape(CustomCorners(corners: [.topLeft, .topRight], radius: 30))
                .edgesIgnoringSafeArea(.bottom) // Extend to bottom of screen
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .navigationBarHidden(true) // Hide navigation bar for the onboarding view itself
    }
}

// Custom component for category pills
struct CategoryPill: View {
    let text: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 5) {
            if icon == "heart.fill" && text == "Relationship" {
                Image(systemName: icon)
                    .foregroundColor(.red)
                    .font(.system(size: 10))
            } else {
                Image(systemName: icon)
                    .foregroundColor(color == .white ? .black : .white)
                    .font(.system(size: 10))
            }
            
            Text(text)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(color == .white ? .black : .white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(color.opacity(color == .white ? 1 : 0.8))
        .cornerRadius(20)
    }
}

// SwiftUI-only custom corners shape
struct CustomCorners: Shape {
    var corners: Set<RectCorner>
    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let tl = corners.contains(.topLeft)
        let tr = corners.contains(.topRight)
        let bl = corners.contains(.bottomLeft)
        let br = corners.contains(.bottomRight)
        
        let width = rect.width
        let height = rect.height
        
        // Top left corner
        if tl {
            path.move(to: CGPoint(x: 0, y: radius))
            path.addArc(center: CGPoint(x: radius, y: radius),
                        radius: radius,
                        startAngle: Angle(degrees: 180),
                        endAngle: Angle(degrees: 270),
                        clockwise: false)
        } else {
            path.move(to: CGPoint(x: 0, y: 0))
        }
        
        // Top right corner
        if tr {
            path.addLine(to: CGPoint(x: width - radius, y: 0))
            path.addArc(center: CGPoint(x: width - radius, y: radius),
                        radius: radius,
                        startAngle: Angle(degrees: 270),
                        endAngle: Angle(degrees: 0),
                        clockwise: false)
        } else {
            path.addLine(to: CGPoint(x: width, y: 0))
        }
        
        // Bottom right corner
        if br {
            path.addLine(to: CGPoint(x: width, y: height - radius))
            path.addArc(center: CGPoint(x: width - radius, y: height - radius),
                        radius: radius,
                        startAngle: Angle(degrees: 0),
                        endAngle: Angle(degrees: 90),
                        clockwise: false)
        } else {
            path.addLine(to: CGPoint(x: width, y: height))
        }
        
        // Bottom left corner
        if bl {
            path.addLine(to: CGPoint(x: radius, y: height))
            path.addArc(center: CGPoint(x: radius, y: height - radius),
                        radius: radius,
                        startAngle: Angle(degrees: 90),
                        endAngle: Angle(degrees: 180),
                        clockwise: false)
        } else {
            path.addLine(to: CGPoint(x: 0, y: height))
        }
        
        path.closeSubpath()
        return path
    }
}

// Login view modifications needed next (changing StateObject to EnvironmentObject)
struct LoginView: View {
    @Environment(\.presentationMode) var presentationMode
    // @StateObject private var viewModel = AuthenticationViewModel() // REMOVE THIS
    @EnvironmentObject var viewModel: AuthenticationViewModel // ADD THIS

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background image
                Image("city")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Logo at top
                    Text("FaithDate")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 60)
                    
                    Spacer()
                    
                    // Container with rounded top corners only
                    VStack(spacing: 0) {
                        // Header section
                        VStack(spacing: 15) {
                            Text("Start To Find Your Ideal Relationship")
                                .font(.system(size: 22, weight: .bold))
                                .multilineTextAlignment(.center)
                                .padding(.top, 25)
                                .padding(.horizontal, 20)
                            
                            Text("Create a unique emotional story that describes better than words")
                                .font(.system(size: 15))
                                .foregroundColor(Color.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 25)
                                .padding(.bottom, 20)
                        }
                        
                        // Buttons with rounded corners
                        VStack(spacing: 12) {
                            // Apple button
                            Button(action: {}) { // Placeholder action
                                HStack {
                                    Image(systemName: "apple.logo")
                                        .font(.system(size: 16))
                                    
                                    Text("Continue with Apple")
                                        .font(.system(size: 17, weight: .medium))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                                .background(Color.blue)
                                .cornerRadius(27.5)
                                .padding(.horizontal, 25)
                            }
                            
                            // Google button
                            Button {
                                Task {
                                    await viewModel.signInWithGoogle() // Call ViewModel sign-in method
                                }
                            } label: { // Use label for button content
                                HStack {
                                    Image(systemName: "g.circle.fill")
                                        .font(.system(size: 16))
                                    
                                    Text("Continue with Google")
                                        .font(.system(size: 17, weight: .medium))
                                }
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                                .background(Color.white)
                                .cornerRadius(27.5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 27.5)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                            }
                            .padding(.horizontal, 25) // Apply padding to the button itself
                            
                            // Phone button
                            Button(action: {}) { // Placeholder action
                                HStack {
                                    Image(systemName: "iphone")
                                        .font(.system(size: 16))
                                    
                                    Text("Continue with Phone")
                                        .font(.system(size: 17, weight: .medium))
                                }
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                                .background(Color.yellow)
                                .cornerRadius(27.5)
                                .padding(.horizontal, 25)
                            }
                            .padding(.bottom, 30)
                        }
                        // NavigationLink to SignedInView - THIS IS NO LONGER NEEDED HERE
                        // The navigation is handled by the root ContentView based on state
//                         ZStack {
//                            NavigationLink(
//                                destination: SignedInView(),
//                                isActive: $viewModel.isUserSignedIn,
//                                label: { EmptyView() }
//                            )
//                        }
//                        .frame(width: 0, height: 0)
//                        .opacity(0)
                    }
                    .background(Color.white)
                    .clipShape(CustomCorners(corners: [.topLeft, .topRight], radius: 30))
                    .ignoresSafeArea(edges: .bottom)
                }
                .edgesIgnoringSafeArea(.bottom)
            }
            .alert("Sign-In Error", isPresented: .constant(viewModel.errorMessage != nil), presenting: viewModel.errorMessage) { _ in
                 Button("OK") {
                    viewModel.errorMessage = nil
                 }
            } message: { message in
                 Text(message)
            }
        }
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea()
        .gesture(DragGesture().onEnded { gesture in
            // Allow swipe back - LoginView should always be dismissable this way
            if gesture.translation.width > 100 {
                 self.presentationMode.wrappedValue.dismiss()
            }
         })
        // REMOVE the onAppear check - parent handles initial state
//        .onAppear {
//            viewModel.checkCurrentUser()
//        }
    }
}

#Preview {
    // Preview needs the environment object too now
    ContentView()
        .environmentObject(AuthenticationViewModel())
}
