import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:luxe_nail/main.dart';
import 'package:luxe_nail/screens/ai_result_screen.dart';
import 'package:luxe_nail/screens/dashboard_screen.dart';
import 'package:luxe_nail/screens/gallery_screen.dart';
import 'package:luxe_nail/screens/processing_screen.dart';
import 'package:luxe_nail/widgets/dashboard/reservation_card.dart';

/// ===============================
/// HELPERS (lebih stabil dari pumpAndSettle doang)
/// ===============================
Future<void> pumpFor(
  WidgetTester tester,
  Duration total, {
  Duration step = const Duration(milliseconds: 300),
}) async {
  final steps = (total.inMilliseconds / step.inMilliseconds).ceil();
  for (int i = 0; i < steps; i++) {
    await tester.pump(step);
  }
}

Future<void> waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 25),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 300));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('Timeout: tidak menemukan ${finder.description}');
}

Future<void> tapIfExists(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isNotEmpty) {
    await tester.tap(finder.first);
    await pumpFor(tester, const Duration(seconds: 1));
  }
}

Future<void> tapTextIfExists(WidgetTester tester, String text) async {
  final f = find.text(text);
  await tapIfExists(tester, f);
}

bool anyOfTextsExists(List<String> texts) {
  for (final t in texts) {
    if (find.text(t).evaluate().isNotEmpty) return true;
  }
  return false;
}

/// Tap salah satu dari beberapa teks (yang ketemu duluan)
Future<void> tapOneOfTexts(WidgetTester tester, List<String> texts) async {
  for (final t in texts) {
    final f = find.text(t);
    if (f.evaluate().isNotEmpty) {
      await tester.tap(f.first);
      await pumpFor(tester, const Duration(seconds: 1));
      return;
    }
  }
  fail('Tidak menemukan tombol: ${texts.join(" / ")}');
}

/// ===============================
/// LOGIN (stabil: tap by text "Log in")
/// ===============================
Future<void> doLogin(WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  await tester.pumpAndSettle(const Duration(seconds: 10));

  final username = find.widgetWithText(TextField, 'Username');
  final password = find.widgetWithText(TextField, 'Password');
  expect(username, findsOneWidget);
  expect(password, findsOneWidget);

  // ganti sesuai akunmu
  await tester.enterText(username, 'artist2');
  await tester.enterText(password, 'password');

  final loginText = find.text('Log in');
  expect(loginText, findsOneWidget);
  await tester.tap(loginText.first);

  await waitFor(tester, find.byType(DashboardScreen),
      timeout: const Duration(seconds: 30));
  expect(find.byType(DashboardScreen), findsOneWidget);
}

/// ===============================
/// DASHBOARD -> TAP CARD -> GALLERY
/// ===============================
Future<void> openFirstReservationToGallery(WidgetTester tester) async {
  expect(find.byType(DashboardScreen), findsOneWidget);

  await pumpFor(tester, const Duration(seconds: 3));

  final cards = find.byType(ReservationCard);
  expect(cards, findsWidgets);

  await tester.ensureVisible(cards.first);
  await tester.tap(cards.first);

  await waitFor(tester, find.byType(GalleryScreen),
      timeout: const Duration(seconds: 30));
  expect(find.byType(GalleryScreen), findsOneWidget);
}

/// ===============================
/// MASUK TAB CUSTOM DESIGN
/// ===============================
Future<void> goToCustomDesignTab(WidgetTester tester) async {
  // Pastikan tab ada
  await waitFor(tester, find.text('Custom Design'),
      timeout: const Duration(seconds: 20));

  await tester.tap(find.text('Custom Design'));
  await pumpFor(tester, const Duration(seconds: 2));

  // minimal evidence: entah label stepper (Shape/Type/...) atau step wizard (Choose Shape)
  final ok = anyOfTextsExists([
    'Shape',
    'Type',
    'Color',
    'Accessory',
    'Choose Shape',
    'Choose Color',
    'Choose Finish',
    'Choose Accessory',
    'Step 1/5',
    'Step 2/5',
  ]);

  expect(ok, true,
      reason: 'Custom Design tab tidak tampil (anchor UI tidak ketemu).');
}

/// ===============================
/// TAP PILIHAN DI STEP (yang aman: tap Image visible)
/// - Ini biasanya grid item pilihan (shape/type/color/accessory)
/// ===============================
Future<void> tapFirstVisibleChoice(WidgetTester tester) async {
  // Cari Image yang visible (grid item biasanya Image)
  final images = find.byType(Image);
  if (images.evaluate().isNotEmpty) {
    await tester.tap(images.first);
    await pumpFor(tester, const Duration(seconds: 1));
    return;
  }

  // fallback
  final inkwell = find.byType(InkWell);
  if (inkwell.evaluate().isNotEmpty) {
    await tester.tap(inkwell.first);
    await pumpFor(tester, const Duration(seconds: 1));
    return;
  }

  final gesture = find.byType(GestureDetector);
  if (gesture.evaluate().isNotEmpty) {
    await tester.tap(gesture.first);
    await pumpFor(tester, const Duration(seconds: 1));
    return;
  }

  fail(
      'Tidak menemukan item pilihan yang bisa di-tap (Image/InkWell/GestureDetector).');
}

/// ===============================
/// MAJU STEP kalau UI kamu pakai tombol Next/Lanjut
/// (kalau auto-advance, dia bakal skip karena gak ketemu)
/// ===============================
Future<void> tapNextIfExists(WidgetTester tester) async {
  await tapTextIfExists(tester, 'Next');
  await tapTextIfExists(tester, 'Lanjut');
  await tapTextIfExists(tester, 'Continue');
}

/// ===============================
/// GENERATE BUTTON:
/// - Versi stepper tab: "Generate & Finish"
/// - Versi CustomDesignView: "Generate Design"
/// ===============================
Future<void> tapGenerate(WidgetTester tester) async {
  final genFinish = find.text('Generate & Finish');
  final genDesign = find.text('Generate Design');

  if (genFinish.evaluate().isNotEmpty) {
    await tester.tap(genFinish.first);
    await pumpFor(tester, const Duration(seconds: 2));
    return;
  }

  if (genDesign.evaluate().isNotEmpty) {
    await tester.tap(genDesign.first);
    await pumpFor(tester, const Duration(seconds: 2));
    return;
  }

  fail(
      'Tombol generate tidak ketemu ("Generate & Finish" / "Generate Design").');
}

/// ===============================
/// Setelah Generate:
/// - Bisa masuk AIResultScreen dulu, lalu "Use This Design"
/// - Atau langsung Processing
/// ===============================
Future<void> proceedToProcessingFromAI(WidgetTester tester) async {
  final ai = find.byType(AIResultScreen);
  final processing = find.byType(ProcessingScreen);

  final end = DateTime.now().add(const Duration(seconds: 120));
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 300));
    if (ai.evaluate().isNotEmpty || processing.evaluate().isNotEmpty) break;
  }

  if (processing.evaluate().isNotEmpty) {
    expect(processing, findsOneWidget);
    expect(find.text('Processing'), findsOneWidget);
    return;
  }

  if (ai.evaluate().isNotEmpty) {
    expect(ai, findsOneWidget);

    final useBtn = find.text('Use This Design (Add to Bill)');
    await waitFor(tester, useBtn, timeout: const Duration(seconds: 60));
    await tester.tap(useBtn.first);

    await waitFor(tester, processing, timeout: const Duration(seconds: 60));
    expect(processing, findsOneWidget);
    expect(find.text('Processing'), findsOneWidget);
    return;
  }

  fail(
      'Setelah Generate tidak masuk AIResultScreen maupun ProcessingScreen (mungkin AI error/limit).');
}

/// ===============================
/// Processing -> Done -> Dialog "Job Completed!" -> OK -> balik Dashboard
/// ===============================
Future<void> finishJobAndVerify(WidgetTester tester) async {
  expect(find.byType(ProcessingScreen), findsOneWidget);

  final doneBtn = find.text('Done (Finish Job)');
  await waitFor(tester, doneBtn, timeout: const Duration(seconds: 30));
  await tester.tap(doneBtn.first);

  final dialogTitle = find.text('Job Completed!');
  await waitFor(tester, dialogTitle, timeout: const Duration(seconds: 60));
  expect(dialogTitle, findsOneWidget);

  final okBtn = find.text('OK');
  await waitFor(tester, okBtn, timeout: const Duration(seconds: 20));
  await tester.tap(okBtn.first);

  await waitFor(tester, find.byType(DashboardScreen),
      timeout: const Duration(seconds: 30));
  expect(find.byType(DashboardScreen), findsOneWidget);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// ======================================================
  /// E2E-M02 (AI) — AKTIF
  /// Login -> pilih customer -> Custom Design -> pilih step sampai tombol generate muncul
  /// -> Generate -> (AIResult) -> Use This Design -> Processing -> Done -> Job Completed
  ///
  ///
  /// ======================================================
  testWidgets(
      'E2E-M02 AI Flow sampai Done (Generate -> Processing -> Completed)',
      (WidgetTester tester) async {
    await doLogin(tester);
    await openFirstReservationToGallery(tester);

    await goToCustomDesignTab(tester);

    // Kunci: tombol generate muncul setelah semua pilihan.
    // Kita brute-force: pilih item beberapa kali + next jika ada,
    // sampai tombol generate terlihat (max loop biar gak infinite).
    for (int i = 0; i < 12; i++) {
      final generateVisible =
          find.text('Generate & Finish').evaluate().isNotEmpty ||
              find.text('Generate Design').evaluate().isNotEmpty;

      if (generateVisible) break;

      await tapFirstVisibleChoice(tester);
      await tapNextIfExists(tester);
      await pumpFor(tester, const Duration(seconds: 1));
    }

    await tapGenerate(tester);

    await proceedToProcessingFromAI(tester);

    await finishJobAndVerify(tester);
  });

  /// ======================================================
  /// E2E-M01 (Templates/manual) — DIMATIKAN
  /// ======================================================
  /*
  testWidgets('E2E-M01 Templates Flow (disabled)', (WidgetTester tester) async {
    // ...
  });
  */
}
