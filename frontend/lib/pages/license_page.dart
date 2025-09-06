import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LicensePage extends StatelessWidget {
  const LicensePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ライセンス'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.tertiary,
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
                      Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1),
                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.copyright,
                      size: 48,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'オープンソースライセンス',
                      style: GoogleFonts.mPlusRounded1c(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'このアプリで使用しているオープンソースソフトウェア',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Flutter関連ライセンス
              _buildLicenseSection(
                context,
                'Flutter Framework',
                'BSD 3-Clause License',
                'Copyright (c) 2014, Google Inc.\n\n'
                'Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:\n\n'
                '1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.\n\n'
                '2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.\n\n'
                '3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.',
                'https://github.com/flutter/flutter',
              ),
              
              _buildLicenseSection(
                context,
                'Google Fonts',
                'Apache License 2.0',
                'Copyright (c) 2021 Google LLC\n\n'
                'Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at\n\n'
                'http://www.apache.org/licenses/LICENSE-2.0\n\n'
                'Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.',
                'https://pub.dev/packages/google_fonts',
              ),
              
              _buildLicenseSection(
                context,
                'Lottie for Flutter',
                'Apache License 2.0',
                'Copyright (c) 2020 Airbnb, Inc.\n\n'
                'Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at\n\n'
                'http://www.apache.org/licenses/LICENSE-2.0\n\n'
                'Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.',
                'https://pub.dev/packages/lottie',
              ),
              
              _buildLicenseSection(
                context,
                'HTTP Package',
                'BSD 3-Clause License',
                'Copyright (c) 2014, the Dart project authors.\n\n'
                'Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:\n\n'
                '• Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.\n'
                '• Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.\n'
                '• Neither the name of Google Inc. nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.',
                'https://pub.dev/packages/http',
              ),
              
              _buildLicenseSection(
                context,
                'Material Icons',
                'Apache License 2.0',
                'Copyright (c) 2014 Google Inc.\n\n'
                'Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at\n\n'
                'http://www.apache.org/licenses/LICENSE-2.0\n\n'
                'Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.',
                'https://fonts.google.com/icons',
              ),
              
              _buildLicenseSection(
                context,
                'M PLUS Rounded 1c Font',
                'SIL Open Font License 1.1',
                'Copyright (c) 2021, M+ FONTS PROJECT\n\n'
                'This Font Software is licensed under the SIL Open Font License, Version 1.1. This license is copied below, and is also available with a FAQ at: http://scripts.sil.org/OFL\n\n'
                'SIL OPEN FONT LICENSE Version 1.1\n\n'
                'PREAMBLE\n'
                'The goals of the Open Font License (OFL) are to stimulate worldwide development of collaborative font projects, to support the font creation efforts of academic and linguistic communities, and to provide a free and open framework in which fonts may be shared and improved in partnership with others.',
                'https://fonts.google.com/specimen/M+PLUS+Rounded+1c',
              ),
              
              const SizedBox(height: 32),
              
              // 免責事項
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'ライセンスについて',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '本アプリは上記のオープンソースソフトウェアを利用して開発されています。各ライブラリの詳細なライセンス条項については、それぞれのプロジェクトページをご確認ください。\n\n'
                      'すべてのライセンスは各著作権者の権利を尊重し、適切に遵守されています。',
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

  Widget _buildLicenseSection(BuildContext context, String title, String licenseType, String content, String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: ExpansionTile(
        title: Text(
          title,
          style: GoogleFonts.mPlusRounded1c(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
        subtitle: Text(
          licenseType,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
        leading: Icon(
          Icons.article,
          color: Theme.of(context).colorScheme.tertiary,
        ),
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    height: 1.4,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.link,
                      size: 16,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        url,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.tertiary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}