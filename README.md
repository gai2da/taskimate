# TaskiMate

**TaskiMate** is a gamified task management app for **iOS** designed to support adults with ADHD. It combines flexible scheduling, progress tracking, and motivational features to help users manage tasks efficiently while staying engaged. The app incorporates accessibility features, gamification elements, and psychological principles to improve productivity and self-regulation.

## Features

- **Task Management**: Create, edit, and organise tasks and subtasks with flexible scheduling.  
- **Progress Tracking**: Visualise task progress using a mind-map style layout.  
- **Gamification**: Earn points, customise an avatar, and receive motivational messages.  
- **Calendar Integration**: Sync tasks with the device calendar.  
- **iOS Widget**: Quick access to tasks and progress from the home screen.  
- **Accessibility**: Dark mode, text-to-speech (TTS), speech-to-text (STT), adjustable font sizes, and notifications.  
- **ADHD-Friendly Design**: Flexible task management, positive reinforcement, and visual feedback.


## Install Flutter dependencies:
flutter pub get

## Run the app on an emulator or connected device:
flutter run


## Architecture

TaskiMate follows the **MVVM (Model-View-ViewModel)** architecture:

- **Model**: Task and user data structures, Firebase integration.  
- **View**: Flutter UI components, widgets, and screens.  
- **ViewModel**: Business logic, state management, and interactions between Model and View.  

## Tech Stack

- **Frontend**: Flutter  
- **Backend**: Firebase (Firestore, Authentication)  
- **State Management**: Provider / Riverpod  
- **Visualization**: Graphite package for mind-map style progress tracking  

## Design Principles

- ADHD-friendly interface with flexible scheduling  
- Positive reinforcement and motivational feedback  
- Accessibility-focused design for text, speech, and notifications  
