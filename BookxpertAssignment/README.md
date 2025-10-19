# “Reader” App with Offline Support

## 📘 Project Overview
Create a iOS Reader app that fetches and displays news articles
using a public API (e.g. NewsAPI.org or JSONPlaceholder). The app
should support offline viewing, dynamic UI, and clean
architecture.
---

## 🏗 Architecture Notes
This project follows MVVM architecture for clean separation of concerns and testablity :
- Model: Handles data and business logic.
- View: SwiftUI or UIKit UI components.
- ViewModel: Connects View with Model using data binding.

Dependencies are managed through SPM.

---

## ⚙️ Install & Run Instructions

### 1.  Clone the repo:
   `git clone https://github.com/DipakMakwana123/BookxpertAssignment`
- Open `BookxpertAssignment.xcodeproj` 
- Select a simulator or device and run (`Cmd+R`)
- The app defaults to a sample API keyless endpoint; if using a keyed service, set the key in `App/Config.swift` or a `.xcconfig` 


### 2. Install SPM Dependencies
- In XCode -> File -> Add Package and search for this git repo https://github.com/SDWebImage/SDWebImage.git
- Than Add To Project 

### 3. Open the Project in Xcode

    open BookxpertAssignment.xcodeproj


### 4. Build & Run
Press **Cmd+R** to run the app on the simulator or device.

---

## 🧪 Testing Instructions
To run all test cases:

    Cmd + U
This will execute all basic unit and integration tests in the project.

---

## 🐞 Known Issues & Future Improvements
- Add pagination / infinite scroll.  
- Background fetch and silent updates.
- More comprehensive error states and retry logic.
- UI polish and animations (e.g., image placeholders & skeleton loading).
- Add end-to-end UI tests and CI pipeline.


---

## 📚 Libraries Used

| Library    | Purpose |
|------------|----------|
| SDWebImage | This library provides an async image downloader with cache support.
| For convenience, we added categories for UI elements like UIImageView, UIButton,
| MKAnnotationView.|

