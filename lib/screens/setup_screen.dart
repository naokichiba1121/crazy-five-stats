import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/stats_service.dart';
import '../theme/app_theme.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _controller = TextEditingController();
  bool _isConnecting = false;
  String? _errorMsg;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    final url = _controller.text.trim();
    if (url.isEmpty ||
        !url.startsWith('https://script.google.com/macros/s/')) {
      setState(() {
        _errorMsg = 'GAS WebアプリのURLを正しく入力してください';
      });
      return;
    }

    setState(() {
      _isConnecting = true;
      _errorMsg = null;
    });

    final service = context.read<StatsService>();
    service.setGasUrl(url);

    // 少し待ってエラーチェック
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;
    setState(() => _isConnecting = false);

    if (service.error != null) {
      setState(() => _errorMsg = '接続失敗: ${service.error}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // ─── タイトル
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppTheme.neonGreen, width: 1.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'CRAZY FIVE',
                        style: TextStyle(
                          color: AppTheme.neonGreen,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '初期設定',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'スタッフ全員でデータを共有するため\nGoogle スプレッドシートと接続します',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // ─── 手順カード
              _StepCard(
                step: '1',
                color: AppTheme.neonGreen,
                title: 'スプレッドシートを作成',
                body:
                    'Googleドライブで新しいスプレッドシートを作成してください。\nシート名は「Stats」にしてください。',
              ),
              const SizedBox(height: 12),
              _StepCard(
                step: '2',
                color: AppTheme.goldAccent,
                title: 'Apps Script を開く',
                body:
                    'スプレッドシートのメニュー →「拡張機能」→「Apps Script」を開いてください。',
              ),
              const SizedBox(height: 12),
              _StepCard(
                step: '3',
                color: const Color(0xFF4FC3F7),
                title: 'スクリプトを貼り付け',
                body:
                    '画面のコードをすべて削除し、以下のスクリプトを貼り付けて保存（Ctrl+S）してください。',
                hasCode: true,
              ),
              const SizedBox(height: 12),
              _StepCard(
                step: '4',
                color: const Color(0xFFE1306C),
                title: 'Webアプリとしてデプロイ',
                body:
                    '「デプロイ」→「新しいデプロイ」→ 種類:「ウェブアプリ」\n実行者:「自分」\nアクセス:「全員」\n→「デプロイ」→ URLをコピー',
              ),

              const SizedBox(height: 28),

              // ─── URL入力
              const Text(
                'デプロイしたWebアプリのURL',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _controller,
                style: const TextStyle(
                    color: AppTheme.textPrimary, fontSize: 13),
                decoration: InputDecoration(
                  hintText:
                      'https://script.google.com/macros/s/...',
                  hintStyle: TextStyle(
                      color: AppTheme.textSecondary.withValues(alpha: 0.6),
                      fontSize: 12),
                  filled: true,
                  fillColor: AppTheme.bgCard,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: AppTheme.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: AppTheme.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: AppTheme.neonGreen, width: 1.5),
                  ),
                  errorText: _errorMsg,
                  errorStyle: const TextStyle(
                      color: AppTheme.redAlert, fontSize: 11),
                ),
              ),

              const SizedBox(height: 20),

              // ─── 接続ボタン
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isConnecting ? null : _connect,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.neonGreen,
                    foregroundColor: const Color(0xFF0A0A0A),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isConnecting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Color(0xFF0A0A0A)),
                        )
                      : const Text(
                          '⚡  接続してスタート',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5),
                        ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final String step;
  final Color color;
  final String title;
  final String body;
  final bool hasCode;

  const _StepCard({
    required this.step,
    required this.color,
    required this.title,
    required this.body,
    this.hasCode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step,
                style: const TextStyle(
                  color: Color(0xFF0A0A0A),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    height: 1.6,
                  ),
                ),
                if (hasCode) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF050A0F),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: AppTheme.divider.withValues(alpha: 0.5)),
                    ),
                    child: const Text(
                      '↓ 下記のGASコードをご利用ください',
                      style: TextStyle(
                        color: AppTheme.neonGreen,
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
