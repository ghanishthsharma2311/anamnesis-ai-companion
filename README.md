# Anamnesis AI Companion

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![FHIR](https://img.shields.io/badge/FHIR-Health%20Interoperability-005C9C?style=for-the-badge&logo=hl7&logoColor=white)
![OpenAI](https://img.shields.io/badge/OpenAI-ChatGPT-404140?style=for-the-badge&logo=openai&logoColor=white)
![MIT License](https://img.shields.io/badge/License-MIT-blue.svg)

## 🚀 Project Overview

The **Anamnesis AI Companion** is a robust Flutter-based mobile application designed to streamline the process of patient anamnesis (medical history collection). It leverages **FHIR (Fast Healthcare Interoperability Resources)** compliant questionnaires to ensure standardized data capture and integrates with **OpenAI's powerful AI capabilities** for intelligent processing, analysis, and generation of medical insights from patient responses. The application also supports exporting collected data for further use.

This project focuses on secure data handling, user-friendly interface, and the potential to revolutionize how medical history is gathered and utilized in a modern healthcare context.

## ✨ Features

* **FHIR Compliant Questionnaires:** Utilizes structured JSON questionnaires (e.g., `2025-03-26 NursIT Anamnesis FHIR Questionnaire with detailed descriptions.json`) for standardized and comprehensive data collection.
* **OpenAI Integration:** Connects with OpenAI services (e.g., GPT models) to process anamnesis responses, potentially generating summaries, identifying key concerns, or suggesting follow-up questions.
* **Secure Environment Variables:** Employs `.env` files for secure management of API keys and other sensitive configurations, ensuring they are not committed to version control.
* **CSV Data Export:** Allows for easy export of collected anamnesis data into CSV format, facilitating integration with other systems or for further data analysis.
* **Cross-Platform Compatibility:** Built with Flutter, enabling seamless deployment and consistent user experience across Android, iOS, Web, and Desktop platforms.
* **User-Friendly Interface:** Designed with an intuitive and efficient interface to streamline the data entry process for healthcare professionals.

## 🛠️ Technologies Used

* **Flutter:** The UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase.
* **Dart:** The programming language optimized for client-side development.
* **OpenAI API:** For integrating advanced AI models into the application's workflow.
* **FHIR (Fast Healthcare Interoperability Resources):** An industry standard for exchanging healthcare information electronically.
* **JSON:** Used for defining the structured anamnesis questionnaires.
* **CSV:** The format for exporting collected data.

## ⚡ Getting Started

Follow these steps to set up and run the project locally on your development machine.

### Prerequisites

* [Flutter SDK](https://flutter.dev/docs/get-started/install) installed and configured.
* A code editor such as [VS Code](https://code.visualstudio.com/download) or [Android Studio](https://developer.android.com/studio).
* An OpenAI API Key, which you can obtain from the [OpenAI Platform](https://platform.openai.com/).

### Installation

1.  **Clone the repository:**
    Open your terminal (e.g., Git Bash / MINGW64) and clone the project. Remember to replace `your-username` with your actual GitHub username after you create the repository on GitHub.
    ```bash
    git clone [https://github.com/your-username/anamnesis-ai-companion.git](https://github.com/your-username/anamnesis-ai-companion.git)
    cd anamnesis-ai-companion
    ```

2.  **Install Flutter dependencies:**
    Navigate into the cloned project directory and fetch all required Flutter packages.
    ```bash
    flutter pub get
    ```

3.  **Set up Environment Variables:**
    Create a file named `.env` in the **root** of your project (the same directory where `pubspec.yaml` and `README.md` are located).
    Add your OpenAI API key and any other necessary sensitive variables to this file.

    **Example `.env` file content:**
    ```
    OPENAI_API_KEY=sk-your_actual_openai_api_key
    # Add other sensitive variables specific to your application here
    ```
    **Important:** Due to the `.gitignore` setup we completed, the `.env` file **will NOT be committed to your Git repository**, ensuring your sensitive keys remain private.

### Running the Application

1.  **Choose a target device or emulator:**
    List available devices:
    ```bash
    flutter devices
    ```
    Then, select a device ID (e.g., `emulator-5554`) and run the application:
    ```bash
    flutter run -d <device_id>
    ```
    Or, to run on the first available device:
    ```bash
    flutter run
    ```

2.  **For Web (optional):**
    ```bash
    flutter run -d chrome
    ```
    *(You can replace `chrome` with other web browsers if installed.)*

## 📸 App Screenshots & Examples

<h3 align="center">Application Interface and Functionality</h3>

<p align="center">
  <img src="screenshots/initial_display.png" alt="Data Entry UI" width="30%" />
  <img src="screenshots/while_analysing_with_transcript.png" alt="Analysing" width="30%" />
  <img src="screenshots/analysis_result.png" alt="AI Result" width="30%" />
</p>

<p align="center">
  <em>Anamnesis data entry, GPT-based analysis in progress, and result output</em>
</p>

<p align="center">
  <img src="screenshots/to_csv.png" alt="Share as CSV" width="45%" />
  <img src="screenshots/csv.jpg" alt="CSV File Example" width="45%" />
</p>

<p align="center">
  <em>Export and share results via CSV</em>
</p>


## 📊 Project Flow Diagram

```mermaid
graph TD
    %% --- App Initialization ---
    subgraph App Initialization
        A[main.dart] --> B["Loads .env variables"]
        B --> C["Starts Flutter App\nMyApp Widget"]
    end

 %% --- User Interface ---
    subgraph User Interface
        C --> D["AnamnesisScreen UI"]
        D --> E["TextFormField: User enters transcript"]
        D --> F["User taps 'Analysieren' button\n_calls _analyzeTranscript()_"]
    end

%% --- Data Processing & AI Integration ---
    subgraph Data Processing & AI Integration
        F --> G1["Set _isLoading = true_\nShow loading indicator"]
        F --> H["Load Questionnaire\nQuestionnaireService.loadQuestionnaire()"]
        H --> I["FHIR Questionnaire JSON"]
        I --> F
        F --> J["Analyze Transcript\nOpenAIService.analyzeTranscript()"]
        J --> K["Builds prompt (transcript + questionnaire)\nCalls OpenAI API"]
        K --> L["API returns response JSON (linkId, answer)"]
        L --> M["Parse response\n_parseApiResponse()"]
        M --> N["Find matching questions\n_findQuestionText()"]
        N --> O["Returns List of structured data\nList<AnamnesisResult>"]
        G1 --> P["Update UI state"]
        O --> P
    end

%% --- Results Display ---
    subgraph Results Display
        P --> Q["Display results\n_render as cards_"]
        P --> R["If error: Show error message"]
        R --> F
    end

%% --- Data Export ---
    subgraph Data Export
        Q --> S["User taps 'Export to CSV'"]
        S --> T["Convert results to CSV\nCSVExporter.exportResults()"]
        T --> U["Write to temporary CSV file"]
        T --> V["Trigger share dialog"]
    end

%% --- Styling for clarity ---
    style K fill:#e0f2f7,stroke:#64b5f6,stroke-width:2px,color:#000
    style I fill:#fff8e1,stroke:#ffb300,stroke-width:2px,color:#000
    style O fill:#e8f5e9,stroke:#81c784,stroke-width:2px,color:#000
    style U fill:#f3e5f5,stroke:#ba68c8,stroke-width:2px,color:#000
    style V fill:#ffebee,stroke:#ef5350,stroke-width:2px,color:#000

