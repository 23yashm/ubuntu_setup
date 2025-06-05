Setup VirtualBox
1. Download appropriate image from google drive (AMD64 or ARM based on your system)
2. Visit https://www.virtualbox.org/wiki/Downloads and download and install appropriate platform package
3. Open "Oracle VirtualBox Manager"
4. Click on "Import" to add downloaded .ova image 
5. Once loaded, open the image by double clicking over it (in the left panel)
6. Login into Ubuntu. Password for wishuser: wish2025
7. Double click on "Run Tests" icon on desktop to run tests

WiSH course contents
   Path: /home/wishuser/wish25-course

Setup Github on VirtualBox
1. Open repository https://github.com/wish-2025/wish25-course in your browser (make sure you are logged in on browser)
2. Click on Fork -> Create Fork
3. Click on Code -> HTTPS -> copy the link (for later)

4. Open terminal on VirtualBox
5. Run `gh auth login`
6. Select "GitHub.com" and press enter
7. Select "HTTPS" and press enter
8. Type `y` and press enter
9. Select "Login with a web browser" and press enter
10. Copy the one-time code and press enter
11. Web browser will open, follow the process there (paste the one-time code copied in 10th step) and authorize github

12. Run following commands replacing your <emaiid> and <name>
    ```
    git config --global user.email "<github-email-id>"
    git config --global user.name "<name>"
    ```
13. cd to wish course content directory: /home/wishuser/wish25-course
14. run command: `git remote add fork <link-copied-in-step-3>`
15. Now you can make commits on master or new branch and push using: `git push fork <branch-name>`
16. Open your forked repo (link copied in 3rd step), and create a pull request

