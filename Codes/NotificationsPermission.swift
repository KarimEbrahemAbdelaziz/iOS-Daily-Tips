// Provisional Notification is new type of options used 
// when request Notification authorization. When you add this to options, 
// and send notification to use it would NOT request authorization 
// at the moment. But it only will appear in notification center 
// with Question if you want to stop this Application from send notification 
// or continue recieve from it.

UNUserNotificationCenter.current().delegate = self
UNUserNotificationCenter.current()
        .requestAuthorization(options: [.alert, .sound, .badge, .provisional]) { (granted, error) in
            if !granted {
                // Alert user if he not allow notifications
            }
        }