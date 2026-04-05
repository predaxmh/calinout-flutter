# Calinout Flutter App

A Calorie- and nutrition-tracking Flutter app focuses on tracking with an appealing design.

# Features
- Dashboard that calculates your calories and macros
- A food type library page that allows the user to create a food type reference for the user's intakes
- The user can create and manage food and meal(contains many foods) logs,
- Weight page, the user manages their weight
- A template page, the user can save meals and foods that they consistently consume and quickly add with a click
- A profile page
- The app focuses on tracking nutrients and calories only with a colorful design

## Architecture
- The project has two main folders /core and /features
- the core folder has all shared dependencies, modes, utils, and widgets:
    /config => router(goRoute) - routes - app config(flutter_dotenv)
    /database => hive config
    /networking => Dio
    /logger
    ...
    
  - Features, separated into three layers:
     data layer => (/source => api class, interface(), Dtos ) we handle the api request and return the DTO only)
                   (/cache => hive models, cache class )
                   (/repositories => repository that implements the interface from the domain)
                  The repository depends on the interface in the source; we can change from api to another data source (local or Firebase)
                  
                  
    domain layer => here we keep the app model clean and related to the app, and the repositories(interfaces) 
- I use data layer for api calls and cache with an interface using

<p float="left">
  <img src="screenshots/Screenshot_2026-04-05-14-55-27-587_com.example.calinout.jpg" width="200"/>
  <img src="screenshots/Screenshot_2026-04-05-14-55-32-562_com.example.calinout.jpg" width="200"/>
  <img src="screenshots/Screenshot_2026-04-05-14-55-37-344_com.example.calinout.jpg" width="200"/>
  <img src="screenshots/Screenshot_2026-04-05-15-45-44-236_com.example.calinout.jpg" width="200"/>
  <img src="screenshots/Screenshot_2026-04-05-15-45-47-705_com.example.calinout.jpg" width="200"/>
  <img src="screenshots/Screenshot_2026-04-05-15-45-54-307_com.example.calinout.jpg" width="200"/>
  <img src="screenshots/Screenshot_2026-04-05-15-46-03-650_com.example.calinout.jpg" width="200"/>
  <img src="screenshots/Screenshot_2026-04-05-15-46-12-017_com.example.calinout.jpg" width="200"/>
</p>


## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
