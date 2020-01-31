# CloudioWare
A top down one-on-one online racing game powered by iCloud and Firebase.   

![alt text](https://raw.githubusercontent.com/tpiske22/CloudioWare/master/Screenshots/IMG_3356.PNG)  

![alt text](https://raw.githubusercontent.com/tpiske22/CloudioWare/master/Screenshots/IMG_3357.PNG)  

![alt text](https://raw.githubusercontent.com/tpiske22/CloudioWare/master/Screenshots/IMG_3358.PNG)  

![alt text](https://raw.githubusercontent.com/tpiske22/CloudioWare/master/Screenshots/IMG_3360.PNG) 
  
  (Note: the Firebase server is current disabled now that this app is on a public repo).  
  
  CloudioWare Racing was conceived as a proof-of-concept application, the concept being to host realtime multiplayer matches using one of the backend services we’ve focused on in my Mobile Backends class - either Google Cloud Platform's AppEngine, Firebase, or iCloud. For rapid-protyping, Firebase’s Realtime Database was the obvious choice. It provides a server-side database capable of low-latency reads, writes, and, most importantly, data syncing across multiple clients, right out of the box.  
  
  The app’s remaining backend supported features are provided by iCloud, for several reasons. iCloud’s authentication is seamless - users don't have to fool with giving their Gmail to yet another service and I don't have to set up yet another sign up page. It provides a simple, free way to push silent and visible notifications to users, critical to circulating game invites and responses. iCloud’s free storage makes the development process worry-free, and makes both the user base and DLC offering largely expandable if the app were to gain a wide audience.  
  
At a high level, the app’s technical details are easy to understand.  
1. When a user launches the app, user profile information and DLC car information is pulled from iCloud for later use throughout the app.  
2. Challenges are sent from user to user via push notifications. The challenger’s challenge is saved in the iCloud database, which is seen by the challenged user via their challenge-created subscription.  
3. Challenge responses are sent when a user responds to an invite, which updates the challenge record in iCloud, sending a silent notification to the challenger.  
4. Race matches are hosted in Firebase Realtime Database. At the start of the race, a fresh race state with a unique ID is created in the database. Players update and listen to that unique game match as they race.  
5. Users buy new cars by updating their profile’s cars field after a purchase.
