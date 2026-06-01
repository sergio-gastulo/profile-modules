using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using System.Windows.Media.Effects;
using System.Windows.Shapes;
using System.Threading;

namespace RemindMe
{

    class ReminderWindow : Window
    {
        private Button _dismissBtn;

        public ReminderWindow(string title, string message)
        {
            // --- Window properties ---
            Title                  = "Reminder";
            Width                  = 380;
            SizeToContent          = SizeToContent.Height;
            WindowStyle            = WindowStyle.None;
            AllowsTransparency     = true;
            Background             = Brushes.Transparent;
            WindowStartupLocation  = WindowStartupLocation.Manual;
            Topmost                = true;
            ShowInTaskbar          = false;
            ResizeMode             = ResizeMode.NoResize;

            Content = BuildLayout(title, message);
            Loaded += OnLoaded;
        }

        private void OnLoaded(object sender, RoutedEventArgs e)
        {
            System.Media.SystemSounds.Asterisk.Play();
        }

        private UIElement BuildLayout(string title, string message)
        {
            // --- Outer border (margin + drop shadow) ---
            var outerBorder = new Border
            {
                Margin       = new Thickness(12),
                CornerRadius = new CornerRadius(14),
                Effect       = new DropShadowEffect
                {
                    Color       = Colors.Black,
                    Opacity     = 0.2,
                    BlurRadius  = 24,
                    ShadowDepth = 4,
                    Direction   = 270
                }
            };

            // --- Inner border (cream background, clipped) ---
            var innerBorder = new Border
            {
                CornerRadius = new CornerRadius(14),
                ClipToBounds = true,
                Background   = new SolidColorBrush((Color)ColorConverter.ConvertFromString("#FDF6EC"))
            };
            outerBorder.Child = innerBorder;

            // --- Main stack panel ---
            var stack = new StackPanel
            {
                Margin = new Thickness(28, 22, 28, 24)
            };
            innerBorder.Child = stack;

            // --- Header row (bell + "R E M I N D E R") ---
            var headerRow = new StackPanel
            {
                Orientation = Orientation.Horizontal,
                Margin      = new Thickness(0, 0, 0, 12)
            };

            var bell = new TextBlock
            {
                Text              = "\U0001F514",
                FontSize          = 18,
                VerticalAlignment = VerticalAlignment.Center,
                Margin            = new Thickness(0, 0, 8, 0)
            };

            var label = new TextBlock
            {
                Text              = "R E M I N D E R",
                FontFamily        = new FontFamily("Georgia"),
                FontSize          = 11,
                FontWeight        = FontWeights.Bold,
                Foreground        = new SolidColorBrush((Color)ColorConverter.ConvertFromString("#E8622A")),
                VerticalAlignment = VerticalAlignment.Center
            };

            headerRow.Children.Add(bell);
            headerRow.Children.Add(label);
            stack.Children.Add(headerRow);

            // --- Title text ---
            var titleBlock = new TextBlock
            {
                Text           = title,
                FontFamily     = new FontFamily("Georgia"),
                FontSize       = 20,
                FontWeight     = FontWeights.Bold,
                Foreground     = new SolidColorBrush((Color)ColorConverter.ConvertFromString("#1C1107")),
                TextWrapping   = TextWrapping.Wrap,
                Margin         = new Thickness(0, 0, 0, 10)
            };
            stack.Children.Add(titleBlock);

            // --- Message text ---
            var messageBlock = new TextBlock
            {
                Text         = message,
                FontFamily   = new FontFamily("Palatino Linotype"),
                FontSize     = 14,
                Foreground   = new SolidColorBrush((Color)ColorConverter.ConvertFromString("#5C4A32")),
                TextWrapping = TextWrapping.Wrap,
                Margin       = new Thickness(0, 0, 0, 22)
            };
            stack.Children.Add(messageBlock);

            // --- Divider ---
            var divider = new Border
            {
                Height     = 1,
                Background = new SolidColorBrush((Color)ColorConverter.ConvertFromString("#EAD9C4")),
                Margin     = new Thickness(0, 0, 0, 18)
            };
            stack.Children.Add(divider);

            // --- Button row ---
            var buttonRow = new StackPanel
            {
                Orientation         = Orientation.Horizontal,
                HorizontalAlignment = HorizontalAlignment.Right
            };

            _dismissBtn = BuildDismissButton("Got it");
            _dismissBtn.Click += (_, __) => Close();

            buttonRow.Children.Add(_dismissBtn);
            stack.Children.Add(buttonRow);

            return outerBorder;
        }

        private Button BuildDismissButton(string content)
        {
            var accentColor = (Color)ColorConverter.ConvertFromString("#E8622A");
            var accentBrush = new SolidColorBrush(accentColor);

            var button = new Button
            {
                Content         = content,
                Foreground      = Brushes.White,
                FontFamily      = new FontFamily("Georgia"),
                FontSize        = 13,
                Padding         = new Thickness(28, 10, 28, 10),
                Cursor          = System.Windows.Input.Cursors.Hand,
                BorderThickness = new Thickness(0),
                Background      = accentBrush
            };

            // Replicate the rounded-corner ControlTemplate
            var factory = new FrameworkElementFactory(typeof(Border));
            factory.SetBinding(Border.BackgroundProperty,
                new System.Windows.Data.Binding("Background")
                {
                    RelativeSource = new System.Windows.Data.RelativeSource(
                        System.Windows.Data.RelativeSourceMode.TemplatedParent)
                });
            factory.SetValue(Border.CornerRadiusProperty, new CornerRadius(6));
            factory.SetBinding(Border.PaddingProperty,
                new System.Windows.Data.Binding("Padding")
                {
                    RelativeSource = new System.Windows.Data.RelativeSource(
                        System.Windows.Data.RelativeSourceMode.TemplatedParent)
                });

            var presenterFactory = new FrameworkElementFactory(typeof(ContentPresenter));
            presenterFactory.SetValue(ContentPresenter.HorizontalAlignmentProperty, HorizontalAlignment.Center);
            presenterFactory.SetValue(ContentPresenter.VerticalAlignmentProperty,   VerticalAlignment.Center);
            factory.AppendChild(presenterFactory);

            button.Template = new ControlTemplate(typeof(Button))
            {
                VisualTree = factory
            };

            return button;
        }
    }



    public class App
    {
        private static Application _app;
        private static Thread _appThread;
        private static readonly object _lock = new object();

        private static void EnsureApplication()
        {
            lock (_lock)
            {
                if (_app != null) return;

                var ready = new ManualResetEventSlim(false);

                _appThread = new Thread(() =>
                {
                    _app = new Application
                    {
                        ShutdownMode = ShutdownMode.OnExplicitShutdown
                    };
                    ready.Set();
                    _app.Run();
                });

                _appThread.SetApartmentState(ApartmentState.STA);
                _appThread.IsBackground = true;
                _appThread.Start();

                ready.Wait();
            }
        }

        public static void Launch(int seconds, string message)
        {
            EnsureApplication();

            var timer = new Timer(_ =>
            {
                _app.Dispatcher.Invoke(() =>
                {
                    var window = new ReminderWindow("Reminder!", message);
                    window.Show();
                });
            }, null, seconds * 1000, Timeout.Infinite);
        }
    }
}