import 'package:android_tv_frontend/data/dummy_fitness.dart';
import 'package:android_tv_frontend/data/dummy_weather.dart';
import 'package:android_tv_frontend/main.dart';
import 'package:android_tv_frontend/screens/workout_detail_screen.dart';
import 'package:android_tv_frontend/widgets/weather/current_conditions_card.dart';
import 'package:android_tv_frontend/widgets/weather/hourly_forecast_row.dart';
import 'package:android_tv_frontend/widgets/weather/weekly_forecast_grid.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Helper to pump the full app with theme and FocusConfig as in production.
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const TVDashboardApp());
    await tester.pumpAndSettle();
  }

  testWidgets('HomeDashboard renders Weather and Fitness section headers',
      (WidgetTester tester) async {
    await pumpApp(tester);

    expect(find.text('Weather'), findsOneWidget);
    expect(find.text('Fitness'), findsOneWidget);

    // Also verify AppBar title presence to ensure we're on the dashboard.
    expect(find.textContaining('Weather + Fitness'), findsOneWidget);
  });

  testWidgets('Weather section shows current conditions snippet and forecasts render items',
      (WidgetTester tester) async {
    await pumpApp(tester);

    // Current conditions card should show temperature and condition string like "22°C • Partly Cloudy"
    expect(find.byType(CurrentConditionsCard), findsOneWidget);
    expect(find.textContaining('${dummyCurrent.temperatureC}°C'), findsWidgets);
    expect(find.textContaining(dummyCurrent.condition), findsWidgets);

    // Hourly forecast row should render a non-zero number of cards/items.
    final hourlyRowFinder = find.byType(HourlyForecastRow);
    expect(hourlyRowFinder, findsOneWidget);

    // Because HourlyForecastRow builds FocusableCards, count by text labels from dummyHourly
    for (final h in dummyHourly) {
      expect(find.text(h.hourLabel), findsWidgets);
    }
    // Smoke check: there should be at least as many temperature labels as hourly items.
    int hourlyTempMatches = 0;
    for (final h in dummyHourly) {
      hourlyTempMatches += tester.widgetList(find.text('${h.tempC}°C')).length;
    }
    expect(hourlyTempMatches, greaterThan(0));

    // Weekly forecast grid should render items for each day label.
    final weeklyGridFinder = find.byType(WeeklyForecastGrid);
    expect(weeklyGridFinder, findsOneWidget);

    for (final d in dummyWeekly) {
      expect(find.text(d.dayLabel), findsWidgets);
    }
    // Smoke check for highs and lows existing somewhere in the tree
    int weeklyHighs = 0;
    int weeklyLows = 0;
    for (final d in dummyWeekly) {
      weeklyHighs += tester.widgetList(find.text('H ${d.highC}°')).length;
      weeklyLows += tester.widgetList(find.text('L ${d.lowC}°')).length;
    }
    expect(weeklyHighs, greaterThan(0));
    expect(weeklyLows, greaterThan(0));
  });

  testWidgets('Selecting a fitness card navigates to WorkoutDetailScreen',
      (WidgetTester tester) async {
    await pumpApp(tester);

    // Use a safe tap on the card by its title, avoiding keyboard events in tests.
    final firstWorkout = workouts.first;
    final workoutTitleFinder = find.text(firstWorkout.title);
    expect(workoutTitleFinder, findsWidgets);

    // Tap the first visible instance of the workout title.
    await tester.tap(workoutTitleFinder.first);
    await tester.pumpAndSettle();

    // Verify we navigated to the detail screen by checking for the AppBar title
    // and the big timer text (MM:SS).
    expect(find.byType(WorkoutDetailScreen), findsOneWidget);
    expect(find.text(firstWorkout.title), findsWidgets);

    // Initial time should be totalMinutes * 60 formatted as mm:ss
    final expectedMinutes = firstWorkout.totalMinutes.toString().padLeft(2, '0');
    expect(find.textContaining('$expectedMinutes:'), findsWidgets);

    // Confirm presence of Start/Stop/Reset controls
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Stop'), findsOneWidget);
    expect(find.text('Reset'), findsOneWidget);
  });
}
