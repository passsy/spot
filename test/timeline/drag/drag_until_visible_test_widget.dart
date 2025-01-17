import 'package:dartx/dartx.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DragUntilVisibleSingleDirectionTestWidget extends StatelessWidget {
  const DragUntilVisibleSingleDirectionTestWidget({
    super.key,
    required this.axis,
    this.ignorePointerAtIndices = const [0, 0],
    this.useColumnOrRow = false,
  });

  Color getRandomColor(int index) {
    return index.isEven ? Colors.red : Colors.blue;
  }

  final Axis axis;
  final List<int> ignorePointerAtIndices;
  final bool useColumnOrRow;

  @override
  Widget build(BuildContext context) {
    final items = List.generate(
      30,
      (index) {
        return IgnorePointer(
          ignoring: ignorePointerAtIndices.contains(index),
          child: Container(
            height: 100,
            color: index.isEven ? Colors.red : Colors.blue,
            child: Center(child: Text('Item at index: $index')),
          ),
        );
      },
    );

    final list = () {
      if (useColumnOrRow) {
        if (axis == Axis.vertical) {
          return SingleChildScrollView(
            child: Column(
              children: items,
            ),
          );
        } else {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: items,
            ),
          );
        }
      }
      return ListView.builder(
        scrollDirection: axis,
        itemCount: items.length,
        itemBuilder: (context, index) {
          return items[index];
        },
      );
    }();

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Scrollable Test with axis: $axis'),
        ),
        body: Center(
          child: SizedBox(
            height: 800,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 500,
                  maxHeight: 450,
                ),
                child: list,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DragUntilVisibleInDialogWidget extends StatelessWidget {
  const DragUntilVisibleInDialogWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Future<void> openDialog() async {
      await showDialog(
        context: context,
        builder: (context) {
          return const ModalWrapper();
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scrollable Test in Dialog'),
      ),
      body: Center(
        child: SizedBox(
          height: 800,
          child: Center(
            child: ElevatedButton(
              onPressed: () async => openDialog(),
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      ),
    );
  }
}

class ModalWrapper extends StatelessWidget {
  const ModalWrapper({super.key});

  void _pop(BuildContext context) {
    Navigator.of(context).pop();
  }

  bool canPop(BuildContext context) {
    return Navigator.of(context).canPop();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> createChildren(int parentIndex) {
      return List.generate(
        5,
        (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: _ListItem(
              isSelected: index.isEven,
              onTap: () {},
              title: Text('ParentIndex: $parentIndex, Item at index: $index'),
            ),
          );
        },
      );
    }

    final parents = List.generate(
      10,
      (index) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Parent Index: $index'),
              const SizedBox(height: 8),
              ...createChildren(index),
            ],
          ),
        );
      },
    );

    return SizedBox(
      height: 800,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Center(
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: 200,
                  minWidth: 400,
                  maxWidth: 800,
                ),
                child: CupertinoPopupSurface(
                  isSurfacePainted: false,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black12.withOpacity(0.4),
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                      border: Border.all(color: Colors.white10, width: 0.5),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Colors.black26,
                            border: Border(
                              bottom:
                                  BorderSide(color: Colors.white10, width: 0.5),
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (canPop(context))
                                Positioned(
                                  left: 0,
                                  top: 0,
                                  bottom: 0,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => _pop(context),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Text(
                                          'Close',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: DefaultTextStyle(
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineLarge!,
                                  child: const Text('TITLE'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                minWidth: 230,
                                maxWidth: 230,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: Material(
                                  color: Colors.transparent,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children:
                                          parents.mapIndexed((index, child) {
                                        return child;
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  const _ListItem({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.isSelected,
    this.onTap,
    this.titleMaxLines = 1,
    Color? titleTextColor,
    EdgeInsets? padding,
  })  : _titleTextColor =
            titleTextColor ?? (onTap != null ? Colors.white : Colors.grey),
        _subTitleTextColor = onTap != null ? Colors.white : Colors.grey,
        _padding =
            padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12);

  final Widget title;
  final Widget? icon;
  final Widget? subtitle;
  final Widget? trailing;
  final bool? isSelected;
  final void Function()? onTap;
  final int titleMaxLines;
  final Color _titleTextColor;
  final Color _subTitleTextColor;
  final EdgeInsets _padding;

  @override
  Widget build(BuildContext context) {
    final double height = subtitle != null ? 64 : 48;
    return Container(
      constraints: BoxConstraints(minHeight: height),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: isSelected == true ? Colors.blueGrey : Colors.white60,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: Colors.white.withOpacity(0.2),
            highlightColor: Colors.white.withOpacity(0.1),
            hoverColor: Colors.white.withOpacity(0.1),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: _padding,
                    child: Row(
                      children: [
                        if (icon != null) ...[
                          icon!,
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              DefaultTextStyle(
                                maxLines: titleMaxLines,
                                style: subtitle != null
                                    ? Theme.of(context).textTheme.labelMedium!
                                    : Theme.of(context)
                                        .textTheme
                                        .labelSmall!
                                        .copyWith(
                                          color: _titleTextColor,
                                        ),
                                child: title,
                              ),
                              if (subtitle != null) ...[
                                const SizedBox(height: 4),
                                DefaultTextStyle(
                                  maxLines: 1,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: _subTitleTextColor,
                                      ),
                                  child: subtitle!,
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (trailing != null) ...[
                          const SizedBox(width: 16),
                          DefaultTextStyle(
                            maxLines: 1,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: _subTitleTextColor,
                                ),
                            child: trailing!,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (isSelected == true)
                  Container(
                    width: 4,
                    height: height,
                    color: onTap != null ? Colors.blue : Colors.grey,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
