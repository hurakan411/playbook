import 'package:flutter/material.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プライバシーポリシー'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            'プライバシーポリシー',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text(
            '本アプリでは、サービス提供・改善のために最小限の情報を取り扱います。\n\n'
            '1. 収集する情報：利用状況、エラー情報、任意入力のプロフィールなど\n'
            '2. 利用目的：機能改善、品質向上、問い合わせ対応など\n'
            '3. 第三者提供：法令に基づく場合を除き、原則行いません\n'
            '4. お問い合わせ：アプリ内の問い合わせ窓口よりご連絡ください\n\n'
            '詳細は今後のアップデートで追記されます。',
          ),
        ],
      ),
    );
  }
}