import 'package:flutter/material.dart';

class DebugUrlScreen extends StatefulWidget {
  const DebugUrlScreen({super.key});

  @override
  State<DebugUrlScreen> createState() => _DebugUrlScreenState();
}

class _DebugUrlScreenState extends State<DebugUrlScreen> {
  static const _toolbarHeight = 54.0;

  late final TextEditingController _filterTextController;
  late List<String> _filteredUrls;
  late List<String> _selectedUrls;

  var _isSelectableMode = false;

  @override
  void initState() {
    super.initState();

    _filterTextController = TextEditingController();
    _filteredUrls = [];
    _selectedUrls = [];
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafeArea = MediaQuery.paddingOf(context).bottom;
    final selectedAll = _selectedUrls.length == _filteredUrls.length;
    final bottomBarHeight =
        _isSelectableMode ? _toolbarHeight + bottomSafeArea : 0.0;

    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: AnimatedContainer(
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 150),
        color: Colors.black26,
        height: bottomBarHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SmallTextButton(
                title: selectedAll ? 'Unselect all' : 'Select all',
                onTap: () => _onSelectAll(selectedAll),
              ),
              const Spacer(),
              SmallTextButton(
                title: 'Remove',
                onTap: _selectedUrls.isEmpty ? null : _onRemoveLogs,
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        title: const Text(
          'URL',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          SmallTextButton(
            title: _isSelectableMode ? 'Cancel' : 'Select',
            onTap: _onChangeSelectableMode,
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size(double.infinity, _toolbarHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: SizedBox(
              height: _toolbarHeight,
              child: TextFormField(
                style: const TextStyle(color: Colors.white),
                controller: _filterTextController,
                onChanged: (_) => _filterLogs(),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  hintText: 'Search',
                  hintStyle: const TextStyle(color: Colors.white54),
                  focusedBorder: _border,
                  enabledBorder: _border,
                  border: _border,
                  suffixIcon: _filterTextController.text.isNotEmpty
                      ? SmallIconButton(
                          icon: Icons.cancel_outlined,
                          onTap: _onSearchBarCancel,
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 100, top: 8),
        itemBuilder: (context, index) {
          final item = _filteredUrls.reversed.toList()[index];

          return DebugUrlItem(
            item: item,
            isSelected: _selectedUrls.contains(item),
            isSelectableMode: _isSelectableMode,
            onTap: _isSelectableMode
                ? () => _onItemSelect(item)
                : () => _onDetailsTap(item),
          );
        },
        itemCount: _filteredUrls.length,
      ),
    );
  }

  @override
  void dispose() {
    _filterTextController.dispose();
    super.dispose();
  }

  void _onSearchBarCancel() => setState(
        () {
          _filteredUrls = List.of([]);
          _filterTextController.clear();
        },
      );

  void _onSelectAll(bool selectedAll) => setState(
        () {
          selectedAll
              ? _selectedUrls = []
              : _selectedUrls = List.of(_filteredUrls);
        },
      );

  void _onChangeSelectableMode() => setState(
        () {
          _isSelectableMode = !_isSelectableMode;
          _selectedUrls = [];
        },
      );

  void _onItemSelect(String item) => setState(
        () {
          if (_selectedUrls.contains(item)) {
            _selectedUrls.remove(item);
          } else {
            _selectedUrls.add(item);
          }
        },
      );

  void _onDetailsTap(String log) => debugPrint(log);

  void _onRemoveLogs() {
    showAdaptiveDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF343434),
        title: Text('Remove selected urls'),
        content: Text('Are you sure you want to remove selected urls?'),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () {
              debugPrint('todo Clear');
              Navigator.of(context).pop();
            },
            child: Text(
              'Remove',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _filterLogs() {
    final searchText = _filterTextController.text.toLowerCase();
    final List<String> filteredResults = [];

    setState(() => _filteredUrls = List.of(filteredResults));
  }

  OutlineInputBorder get _border => const OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.white24,
          width: 0,
        ),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      );
}

class DebugUrlItem extends StatelessWidget {
  final String item;
  final bool isSelected;
  final bool isSelectableMode;
  final VoidCallback onTap;

  const DebugUrlItem({
    super.key,
    required this.item,
    required this.isSelected,
    required this.isSelectableMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 4,
            horizontal: 16,
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                width: isSelectableMode ? 56 : 0,
                child: IconButton(
                  onPressed: onTap,
                  icon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      isSelected ? Icons.check_circle : Icons.circle_outlined,
                      color: isSelected ? Colors.blue : Colors.white,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    color: Colors.blue,
                  ),
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: onTap,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$item 1',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$item 2',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SmallIconButton extends StatelessWidget {
  final IconData? icon;
  final VoidCallback onTap;

  const SmallIconButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButtonTheme(
      data: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith<Color?>(
            (states) => states.contains(WidgetState.disabled) ||
                    states.contains(WidgetState.pressed)
                ? Colors.white24
                : Colors.white,
          ),
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (states) => Colors.transparent,
          ),
        ),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class SmallTextButton extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const SmallTextButton({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => TextButtonTheme(
        data: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.resolveWith<Color?>(
              (states) => states.contains(WidgetState.disabled) ||
                      states.contains(WidgetState.pressed)
                  ? Colors.white24
                  : Colors.white,
            ),
            overlayColor: WidgetStateProperty.resolveWith<Color?>(
              (states) => Colors.transparent,
            ),
          ),
        ),
        child: TextButton(
          onPressed: onTap,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
}
