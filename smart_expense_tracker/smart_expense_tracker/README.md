# Smart Expense Tracker — مصروفاتي

تطبيق Flutter لإدارة المصروفات اليومية: تسجيل، تصنيف، إحصائيات ورسوم بيانية.

## المميزات
- إضافة / تعديل / حذف مصروف (سحب لليسار للحذف مع إمكانية التراجع)
- 8 فئات مع أيقونات وألوان
- التنقل بين الأشهر وعرض إجمالي كل شهر
- رسم دائري لتوزيع الفئات + رسم أعمدة لآخر 6 أشهر
- تخزين محلي بـ SQLite (يعمل بدون إنترنت)
- واجهة عربية RTL كاملة

## التشغيل
```
flutter create .          # مرة واحدة لتوليد مجلدات android/ios
flutter pub get
flutter run
```

## الهيكل
```
lib/
  main.dart
  models/expense.dart        # النموذج والفئات والعملة
  db/database_helper.dart    # SQLite
  screens/home_screen.dart
  screens/add_expense_screen.dart
  screens/stats_screen.dart
```
