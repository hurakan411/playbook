import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プライバシーポリシー'),
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
                      Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                      Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.privacy_tip,
                      size: 48,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'つづきのえほん\nプライバシーポリシー',
                      style: GoogleFonts.mPlusRounded1c(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
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
              
              // プライバシーポリシー内容
              _buildSection(
                context,
                '1. 基本方針',
                '当社は、本アプリの利用者（以下「ユーザー」）のプライバシーを尊重し、個人情報の保護に努めます。本プライバシーポリシーは、個人情報の取り扱いについて定めるものです。',
              ),
              
              _buildSection(
                context,
                '2. 収集する情報',
                '本アプリでは、以下の情報を収集する場合があります：\n\n'
                '【自動的に収集される情報】\n'
                '• デバイス情報（機種、OS バージョン等）\n'
                '• アプリの利用状況（使用時間、操作履歴等）\n'
                '• エラーログおよび診断情報\n\n'
                '【ユーザーが作成するコンテンツ】\n'
                '• 絵本のタイトルやテキスト\n'
                '• 作成した絵本の画像データ',
              ),
              
              _buildSection(
                context,
                '3. 情報の利用目的',
                '収集した情報は、以下の目的で利用いたします：\n\n'
                '• サービスの提供・改善\n'
                '• ユーザーサポートの提供\n'
                '• 不正利用の防止\n'
                '• 新機能の開発\n'
                '• 統計データの作成（匿名化処理後）',
              ),
              
              _buildSection(
                context,
                '4. 情報の管理・保護',
                '当社は、収集した個人情報を適切に管理し、以下の対策を実施しています：\n\n'
                '• 暗号化技術による情報の保護\n'
                '• アクセス権限の適切な管理\n'
                '• 定期的なセキュリティ監査の実施\n'
                '• 従業員への個人情報保護教育の実施',
              ),
              
              _buildSection(
                context,
                '5. 第三者への提供',
                '当社は、以下の場合を除き、ユーザーの同意なく第三者に個人情報を提供することはありません：\n\n'
                '• 法令に基づく場合\n'
                '• 人の生命、身体または財産の保護のために必要がある場合\n'
                '• ユーザーの同意がある場合\n'
                '• 業務委託先への必要な範囲での提供（適切な管理の下）',
              ),
              
              _buildSection(
                context,
                '6. Cookie等の取り扱い',
                '本アプリでは、サービス向上のため以下の技術を使用する場合があります：\n\n'
                '• Cookie\n'
                '• ローカルストレージ\n'
                '• 分析ツール\n\n'
                'これらの技術により収集された情報は、統計的な分析にのみ使用し、個人を特定することはありません。',
              ),
              
              _buildSection(
                context,
                '7. ユーザーの権利',
                'ユーザーは、自身の個人情報について以下の権利を有します：\n\n'
                '• 情報の開示請求\n'
                '• 情報の訂正・削除請求\n'
                '• 利用停止請求\n'
                '• データの持ち運び権\n\n'
                'これらの権利を行使される場合は、アプリ内のお問い合わせ機能よりご連絡ください。',
              ),
              
              _buildSection(
                context,
                '8. 子どもの個人情報',
                '本アプリは、13歳未満のお子様の個人情報を保護者の同意なく収集することはありません。保護者の方は、お子様の個人情報について確認・削除を求めることができます。',
              ),
              
              _buildSection(
                context,
                '9. ポリシーの変更',
                '本プライバシーポリシーは、法令の変更やサービスの改善に伴い変更される場合があります。重要な変更については、アプリ内での通知やメール等でお知らせいたします。',
              ),

              const SizedBox(height: 32),
              
              // お問い合わせ情報
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.support_agent,
                          size: 20,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'プライバシーに関するお問い合わせ',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '個人情報の取り扱いに関するご質問やご要望については、アプリ内のサポート機能よりお気軽にお問い合わせください。適切に対応させていただきます。',
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
              color: Theme.of(context).colorScheme.secondary,
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