using System.Windows;
using System.Windows.Controls;
using System.Threading;

namespace RemindMe
{
    public class NotificationWindow : Window
    {
        public NotificationWindow(
            string title,
            string message
        )
        {
            Title = title;
            Width = 380;

            var button = new Button
            {
                Content = "Click me"
            };
            button.Click += Button_Click;

            Content = button;
        }

        void Button_Click(object sender, RoutedEventArgs e)
        {
            MessageBox.Show("Hello, Windows Presentation Foundation!");
        }
    }

    public class App
    {
        public static void Launch(int seconds, string message)
        {
            var thread = new Thread(() =>
            {
                
                Thread.Sleep(seconds * 1000);

                // launch window
                var app = new Application();
                string title = "Reminder!";
                app.Run(new NotificationWindow(title, message));
            });

            // dispose thread
            thread.SetApartmentState(ApartmentState.STA);
            thread.IsBackground = false;
            thread.Start();
        }
    }
}