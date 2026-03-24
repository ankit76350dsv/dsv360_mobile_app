# Image Crop Functionality on Profile Image Upload

## Implementation Steps

### 1. Import Required Libraries
- Added `crop_your_image` package to handle image cropping
- Added `dart:typed_data` to work with image byte data (Uint8List)

### 2. Create Crop Image Navigation Method
- Added `_cropImage()` method in `_ProfilePageState`
- This method opens a new crop page using Navigator.push()
- Returns the cropped File from the crop page

### 3. Modify Image Selection in Upload Method
- In `_pickAndUploadImage()` method, after user selects image
- Call `_cropImage()` to crop the selected image
- Check if crop was cancelled - if null, return early

### 4. Add Mount Check After Crop
- After crop completes, verify widget is still mounted
- Prevents errors if user navigates away during crop

### 5. Use Cropped Image for Upload
- Replace original image path with cropped file path
- Upload cropped file instead of original to server
- Maintains all existing upload logic

### 6. Create Separate Crop Page Widget
- Built `_CropImagePage` as a StatefulWidget
- Takes File as parameter and displays crop interface
- Independent screen for better UX

### 7. Initialize Crop Controller
- Created `CropController` instance in crop page state
- No parameters needed - library handles defaults
- Flag variable `_isProcessing` tracks crop operation

### 8. Create Crop Callback Handler
- Added `_handleCrop()` method
- Receives cropped image as Uint8List (byte data)
- Saves byte data to temporary file using Directory.systemTemp

### 9. Generate Unique Filename for Temp File
- Used timestamp to create unique filenames
- Format: `cropped_profile_{millisecondsSinceEpoch}.jpg`
- Prevents file conflicts

### 10. Display Crop UI Components
- AppBar with title "Crop Profile Photo"
- Close button (X) to cancel crop - goes back without cropping
- Check button (✓) to confirm crop - triggers _handleCrop()

### 11. Add Loading State During Crop
- When processing, show circular progress indicator
- Replaces check button to prevent multiple taps
- Updates UI after save completes

### 12. Configure Crop Widget Settings
- Set `aspectRatio: 1.0` for square profile images
- Set `initialSize: 0.5` for 50% initial crop size
- Set `withCircleUi: true` for circular crop overlay

### 13. Handle Crop Callback
- `onCropped` parameter linked to `_handleCrop()` method
- Called automatically when Crop widget completes

### 14. Save Cropped Bytes to File
- Write Uint8List bytes to temporary file
- Use await for async file operation
- File is ready for immediate upload

### 15. Return Cropped File to Upload
- Use Navigator.pop() with cropped File as result
- Returns to profile page for upload
- Profile page receives File and proceeds with upload

### 16. Error Handling in Crop Page
- Try-catch block wraps entire crop process
- Shows error snackbar if crop fails
- Prevents app crash during crop operation

### 17. Mounted Check in Callback
- Verify widget is still mounted before pop/snackbar
- Prevents memory leaks and navigation errors
- Safe handling of async operations

### 18. Clean Up Processing State
- Finally block resets `_isProcessing` flag
- Ensures UI button returns to normal state
- Happens whether crop succeeds or fails

### 19. Upload Flow Integration
- After crop returns, FormData created with cropped file
- MultipartFile uses cropped file path
- Server receives optimized crop image instead of original

### 20. Success Feedback
- Shows snackbar confirmation after upload
- Updates profile image URL with server response
- Refreshes profile data from backend
