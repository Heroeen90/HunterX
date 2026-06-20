import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';

class TerminalOutputWidget extends StatefulWidget {
  final List<TerminalLine> lines;
  final bool showCursor;
  final double fontSize;
  final VoidCallback? onClear;

  const TerminalOutputWidget({
    super.key,
    required this.lines,
    this.showCursor = false,
    this.fontSize = 12,
    this.onClear,
  });

  @override
  State<TerminalOutputWidget> createState() => _TerminalOutputWidgetState();
}

class _TerminalOutputWidgetState extends State<TerminalOutputWidget>
    with SingleTickerProviderStateMixin {
  final _scrollController = ScrollController();
  late AnimationController _cursorController;

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(TerminalOutputWidget old) {
    super.didUpdateWidget(old);
    if (widget.lines.length != old.lines.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _cursorController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.terminalBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildToolbar(),
          Expanded(
            child: Scrollbar(
              controller: _scrollController,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: widget.lines.length + (widget.showCursor ? 1 : 0),
                itemBuilder: (ctx, i) {
                  if (i == widget.lines.length && widget.showCursor) {
                    return AnimatedBuilder(
                      animation: _cursorController,
                      builder: (_, __) => Text(
                        _cursorController.value > 0.5 ? '█' : ' ',
                        style: TextStyle(
                          color: AppTheme.terminalGreen,
                          fontSize: widget.fontSize,
                          fontFamily: 'monospace',
                        ),
                      ),
                    );
                  }
                  final line = widget.lines[i];
                  return Text(
                    line.text,
                    style: TextStyle(
                      color: line.color,
                      fontSize: widget.fontSize,
                      fontFamily: 'monospace',
                      height: 1.4,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
        ),
        child: Row(
          children: [
            const CircleAvatar(radius: 5, backgroundColor: Color(0xFFFF5F57)),
            const SizedBox(width: 6),
            const CircleAvatar(radius: 5, backgroundColor: Color(0xFFFEBC2E)),
            const SizedBox(width: 6),
            const CircleAvatar(radius: 5, backgroundColor: Color(0xFF28C840)),
            const SizedBox(width: 12),
            Text(
              'terminal',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
            const Spacer(),
            if (widget.onClear != null)
              IconButton(
                onPressed: widget.onClear,
                icon: const Icon(Icons.delete_outline, size: 16),
                color: AppTheme.textSecondary,
                tooltip: 'Clear',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                final text = widget.lines.map((l) => l.text).join('\n');
                Clipboard.setData(ClipboardData(text: text));
              },
              icon: const Icon(Icons.copy, size: 16),
              color: AppTheme.textSecondary,
              tooltip: 'Copy',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      );
}

class TerminalLine {
  final String text;
  final Color color;

  const TerminalLine(this.text, {this.color = AppTheme.terminalGreen});

  factory TerminalLine.stdout(String text) =>
      TerminalLine(text, color: AppTheme.terminalGreen);

  factory TerminalLine.stderr(String text) =>
      TerminalLine(text, color: AppTheme.accent);

  factory TerminalLine.info(String text) =>
      TerminalLine(text, color: AppTheme.secondary);

  factory TerminalLine.warning(String text) =>
      TerminalLine(text, color: AppTheme.warning);

  factory TerminalLine.system(String text) =>
      TerminalLine(text, color: AppTheme.textSecondary);
}
