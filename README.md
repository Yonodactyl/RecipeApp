### Summary: Include screen shots or a video of your app highlighting its features


https://github.com/user-attachments/assets/2250246e-3f30-46ba-9bef-d52c1d2b191e


### Focus Areas: What specific areas of the project did you prioritize? Why did you choose to focus on these areas?
I first focused on ensuring the services provided the necessary data. After establishing this foundation, I prioritized the UI, which I consider crucial because an app needs to be both functional and visually appealing. The user interface creates the first impression when someone uses your app, making it one of the most memorable aspects of the experience.

### Time Spent: Approximately how long did you spend working on this project? How did you allocate your time?
I spent approximately 7 hours on this project over two days. The most time-consuming aspects were writing the tests and refining the UI to meet quality standards.

### Trade-offs and Decisions: Did you make any significant trade-offs in your approach?
While there were no major trade-offs, I chose to support iOS 16 as the minimum version, which meant making some convenience sacrifices since I couldn't utilize Apple's newest APIs. Additionally, I made some compromises in structuring the mock data and tests, resulting in less than 100% coverage.

### Weakest Part of the Project: What do you think is the weakest part of your project?
The weakest aspects are the Views not being divided into smaller, more modular components and the testing plan not being as comprehensive as I would have liked.

### Additional Information: Is there anything else we should know? Feel free to share any insights or constraints you encountered.
During this project, I gained valuable insights about ScrollView's sizing behavior. I encountered an issue where the view would shrink and snap to the left when search results were empty. I resolved this by setting a minimum width large enough to accommodate at least one item, which prevented the unusual UI snapping and shrinking effect.
