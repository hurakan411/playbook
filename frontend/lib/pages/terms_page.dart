import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('利用規約'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ヘッダー
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.description,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'つづきのえほん利用規約',
                      style: GoogleFonts.mPlusRounded1c(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '最終更新日：2024年1月1日',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // 利用規約内容
              _buildSection(
                context,
                '第1条（適用）',
                '本規約は、つづきのえほんアプリ（以下「本アプリ」）の利用条件を定めるものです。ユーザーは本アプリを利用することで、本規約に同意したものとみなします。',
              ),
              
              _buildSection(
                context,
                '第2条（利用登録）',
                '本アプリの利用にあたり、ユーザーは正確かつ最新の情報を提供するものとします。登録情報に虚偽があった場合、利用を停止することがあります。',
              ),
              
              _buildSection(
                context,
                '第3条（禁止事項）',
                '本アプリの利用にあたり、以下の行為を禁止します：\n'
                '• 法令または公序良俗に違反する行為\n'
                '• 犯罪行為に関連する行為\n'
                '• 他のユーザーの迷惑となる行為\n'
                '• 知的財産権を侵害する行為\n'
                '• 本アプリの運営を妨害する行為',
              ),
              
              _buildSection(
                context,
                '第4条（著作権）',
                '本アプリで作成された絵本の著作権は、作成したユーザーに帰属します。ただし、本アプリの改善やサービス提供のため、必要な範囲で利用させていただく場合があります。',
              ),
              
              _buildSection(
                context,
                '第5条（免責事項）',
                '当社は、本アプリの利用によって生じた損害について、一切の責任を負いません。また、本アプリのサービス中断や終了によって生じた損害についても同様です。',
              ),
              
              _buildSection(
                context,
                '第6条（規約の変更）',
                '当社は、必要に応じて本規約を変更することがあります。変更後の規約は、本アプリ内での通知をもって効力を発生するものとします。',
              ),
              
              _buildSection(
                context,
                '第7条（準拠法・管轄裁判所）',
                '本規約は日本法に準拠し、本アプリに関する紛争については、東京地方裁判所を専属的合意管轄裁判所とします。',
              ),

              const SizedBox(height: 32),
              
              // お問い合わせ情報
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.contact_support,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'お問い合わせ',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '本規約に関するご質問やお問い合わせは、アプリ内のサポート機能よりご連絡ください。',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.mPlusRounded1c(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}