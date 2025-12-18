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
/// HELPERS (stabil, tanpa nyangkut pumpAndSettle)
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

/// ===============================
/// LOGIN (versi kamu yang work)
/// ===============================
Future<void> doLogin(WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  await tester.pumpAndSettle(const Duration(seconds: 10));

  final username = find.widgetWithText(TextField, 'Username');
  final password = find.widgetWithText(TextField, 'Password');
  expect(username, findsOneWidget);
  expect(password, findsOneWidget);

  await tester.enterText(username, 'artist1');
  await tester.enterText(password, 'password');

  // Lebih stabil daripada widgetWithText(ElevatedButton, ...) karena kadang button bukan ElevatedButton
  final loginText = find.text('Log in');
  expect(loginText, findsOneWidget);
  await tester.tap(loginText);

  await waitFor(tester, find.byType(DashboardScreen),
      timeout: const Duration(seconds: 30));
}

/// ===============================
/// DASHBOARD -> TAP CARD -> GALLERY
/// ===============================
Future<void> openFirstReservation(WidgetTester tester) async {
  expect(find.byType(DashboardScreen), findsOneWidget);

  await pumpFor(tester, const Duration(seconds: 3));

  final cards = find.byType(ReservationCard);
  expect(cards, findsWidgets);

  await tester.ensureVisible(cards.first);
  await tester.tap(cards.first);

  await waitFor(tester, find.byType(GalleryScreen),
      timeout: const Duration(seconds: 30));
}

/// ===============================
/// Tap gambar pertama yang VISIBLE (buat grid template / grid custom)
/// ===============================
Future<void> tapFirstVisibleImage(WidgetTester tester) async {
  final images = find.byType(Image);
  expect(images, findsWidgets,
      reason: 'Tidak menemukan Image. Grid belum muncul / masih loading.');
  await tester.tap(images.first);
  await pumpFor(tester, const Duration(seconds: 1));
}

/// ===============================
/// Tap tombol kalau ada salah satu text (dipakai buat confirm)
/// ===============================
Future<void> tapOneOfTexts(WidgetTester tester, List<String> texts,
    {Duration after = const Duration(seconds: 1)}) async {
  for (final t in texts) {
    final f = find.text(t);
    if (f.evaluate().isNotEmpty) {
      await tester.tap(f.first);
      await pumpFor(tester, after);
      return;
    }
  }
  fail('Tidak menemukan tombol: ${texts.join(" / ")}');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// ======================================================
  /// IT-M01 — LOGIN + DASHBOARD
  /// ======================================================
  testWidgets('IT-M01 Login berhasil & redirect ke Dashboard',
      (WidgetTester tester) async {
    await doLogin(tester);

    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.text("Today's Appointments"), findsOneWidget);
  });

  /// ======================================================
  /// IT-M04 (TEMPLATES/GALLERY) — Tanpa AI
  /// Dashboard → Gallery → Templates → pilih template → Select This Design → (AIResult/Detail) → Use This Design → Processing
  /// ======================================================
  testWidgets('IT-M04 Templates → Select This Design → Processing (no AI)',
      (WidgetTester tester) async {
    await doLogin(tester);
    await openFirstReservation(tester);

    // Pastikan tab ada & masuk Templates
    expect(find.text('Templates'), findsOneWidget);
    expect(find.text('Custom Design'), findsOneWidget);

    await tester.tap(find.text('Templates'));
    await pumpFor(tester, const Duration(seconds: 2));

    // pilih template (tap gambar)
    await pumpFor(tester, const Duration(seconds: 2));
    await tapFirstVisibleImage(tester);

    // setelah tap template biasanya muncul bottomsheet detail
    // tombol confirm kamu: "Select This Design" (sesuai screenshot)
    await waitFor(tester, find.text('Select This Design'),
        timeout: const Duration(seconds: 20));
    await tester.tap(find.text('Select This Design'));
    await pumpFor(tester, const Duration(seconds: 2));

    // setelah confirm, di project kamu bisa masuk AIResultScreen juga (karena template diarahkan ke AIResultScreen)
    // jadi kita "best effort": tunggu AIResultScreen ATAU langsung Processing (kalau implementasi berbeda)
    final aiScreen = find.byType(AIResultScreen);
    final processing = find.byType(ProcessingScreen);

    // tunggu salah satu muncul
    final end = DateTime.now().add(const Duration(seconds: 60));
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 300));
      if (aiScreen.evaluate().isNotEmpty || processing.evaluate().isNotEmpty) {
        break;
      }
    }

    // jika AIResultScreen muncul, lanjut Use This Design
    if (aiScreen.evaluate().isNotEmpty) {
      expect(aiScreen, findsOneWidget);

      final useBtn = find.text('Use This Design (Add to Bill)');
      await waitFor(tester, useBtn, timeout: const Duration(seconds: 30));
      await tester.tap(useBtn);

      await waitFor(tester, processing, timeout: const Duration(seconds: 60));
      expect(processing, findsOneWidget);
      expect(find.text('Processing'), findsOneWidget);
      return;
    }

    // kalau langsung masuk Processing (tanpa AIResult)
    if (processing.evaluate().isNotEmpty) {
      expect(processing, findsOneWidget);
      expect(find.text('Processing'), findsOneWidget);
      return;
    }

    fail(
        'Tidak masuk AIResultScreen maupun ProcessingScreen setelah Select This Design.');
  });

  /// ======================================================
  /// IT-M04 (AI) — DIMATIKAN (KENa LIMIT)
  /// ======================================================
  /*
  testWidgets('IT-M04 AI Custom Design → Generate & Finish → AIResult/Processing',
      (WidgetTester tester) async {
    await doLogin(tester);
    await openFirstReservation(tester);

    await tester.tap(find.text('Custom Design'));
    await pumpFor(tester, const Duration(seconds: 3));

    // pilih 4 step sampai tombol muncul
    for (int i = 0; i < 4; i++) {
      await tapFirstVisibleImage(tester);
      await pumpFor(tester, const Duration(seconds: 1));
    }

    final btnGenerateFinish = find.text('Generate & Finish');
    await waitFor(tester, btnGenerateFinish, timeout: const Duration(seconds: 15));
    await tester.tap(btnGenerateFinish);

    await waitFor(tester, find.byType(AIResultScreen), timeout: const Duration(seconds: 120));

    final useBtn = find.text('Use This Design (Add to Bill)');
    if (useBtn.evaluate().isNotEmpty) {
      await tester.tap(useBtn);
      await waitFor(tester, find.byType(ProcessingScreen), timeout: const Duration(seconds: 60));
      expect(find.byType(ProcessingScreen), findsOneWidget);
    }
  });
  */

  /// ======================================================
  /// IT-M05 — DIMATIKAN (ubah data real)
  /// ======================================================
  /*
  testWidgets('IT-M05 Done (Finish Job) → muncul notif Job Completed',
      (WidgetTester tester) async {
    // ... (tetap seperti sebelumnya)
  });
  */
}
