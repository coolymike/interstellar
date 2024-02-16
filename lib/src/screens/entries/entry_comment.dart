import 'package:flutter/material.dart';
import 'package:interstellar/src/models/entry_comment.dart';
import 'package:interstellar/src/screens/entries/entry_comment_screen.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/content_item.dart';
import 'package:interstellar/src/widgets/wrapper.dart';
import 'package:provider/provider.dart';

class EntryComment extends StatefulWidget {
  const EntryComment(
    this.comment,
    this.onUpdate, {
    this.opUserId,
    this.onClick,
    super.key,
  });

  final EntryCommentModel comment;
  final void Function(EntryCommentModel) onUpdate;
  final int? opUserId;
  final void Function()? onClick;

  @override
  State<EntryComment> createState() => _EntryCommentState();
}

class _EntryCommentState extends State<EntryComment> {
  bool _isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.only(top: 8),
          child: Wrapper(
            shouldWrap: widget.onClick != null,
            parentBuilder: (child) =>
                InkWell(onTap: widget.onClick, child: child),
            child: ContentItem(
              originInstance:
                  getNameHost(context, widget.comment.user.username),
              body: widget.comment.body ?? '_comment deleted_',
              createdAt: widget.comment.createdAt,
              user: widget.comment.user.username,
              userIcon: widget.comment.user.avatar?.storageUrl,
              userIdOnClick: widget.comment.user.userId,
              opUserId: widget.opUserId,
              boosts: widget.comment.uv,
              isBoosted: widget.comment.userVote == 1,
              onBoost: whenLoggedIn(context, () async {
                var newValue = await context
                    .read<SettingsController>()
                    .kbinAPI
                    .entryComments
                    .putVote(widget.comment.commentId, 1);
                widget.onUpdate(newValue.copyWith(
                  childCount: widget.comment.childCount,
                  children: widget.comment.children,
                ));
              }),
              upVotes: widget.comment.favourites,
              isUpVoted: widget.comment.isFavourited == true,
              onUpVote: whenLoggedIn(context, () async {
                var newValue = await context
                    .read<SettingsController>()
                    .kbinAPI
                    .entryComments
                    .putFavorite(widget.comment.commentId);
                widget.onUpdate(newValue.copyWith(
                  childCount: widget.comment.childCount,
                  children: widget.comment.children,
                ));
              }),
              downVotes: widget.comment.dv,
              isDownVoted: widget.comment.userVote == -1,
              onDownVote: whenLoggedIn(context, () async {
                var newValue = await context
                    .read<SettingsController>()
                    .kbinAPI
                    .entryComments
                    .putVote(widget.comment.commentId, -1);
                widget.onUpdate(newValue.copyWith(
                  childCount: widget.comment.childCount,
                  children: widget.comment.children,
                ));
              }),
              onReply: whenLoggedIn(context, (body) async {
                var newSubComment = await context
                    .read<SettingsController>()
                    .kbinAPI
                    .entryComments
                    .create(
                      body,
                      widget.comment.entryId,
                      parentCommentId: widget.comment.commentId,
                    );

                widget.onUpdate(widget.comment.copyWith(
                  childCount: widget.comment.childCount + 1,
                  children: [newSubComment, ...widget.comment.children!],
                ));
              }),
              onEdit: widget.comment.visibility != 'soft_deleted'
                  ? whenLoggedIn(context, (body) async {
                      var newValue = await context
                          .read<SettingsController>()
                          .kbinAPI
                          .entryComments
                          .edit(
                            widget.comment.commentId,
                            body,
                            widget.comment.lang,
                            widget.comment.isAdult,
                          );
                      widget.onUpdate(newValue.copyWith(
                        childCount: widget.comment.childCount,
                        children: widget.comment.children,
                      ));
                    }, matchesUsername: widget.comment.user.username)
                  : null,
              onDelete: widget.comment.visibility != 'soft_deleted'
                  ? whenLoggedIn(context, () async {
                      await context
                          .read<SettingsController>()
                          .kbinAPI
                          .entryComments
                          .delete(widget.comment.commentId);
                      widget.onUpdate(widget.comment.copyWith(
                        body: '_comment deleted_',
                        uv: null,
                        dv: null,
                        favourites: null,
                        visibility: 'soft_deleted',
                      ));
                    }, matchesUsername: widget.comment.user.username)
                  : null,
              isCollapsed: _isCollapsed,
              onCollapse: widget.comment.childCount > 0
                  ? () => setState(() {
                        _isCollapsed = !_isCollapsed;
                      })
                  : null,
              openLinkUri: Uri.https(
                context.read<SettingsController>().instanceHost,
                '/m/${widget.comment.magazine.name}/t/${widget.comment.entryId}/-/comment/${widget.comment.commentId}',
              ),
            ),
          ),
        ),
        if (widget.comment.childCount > 0 &&
            !_isCollapsed &&
            (widget.comment.children?.isEmpty ?? false))
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EntryCommentScreen(
                  widget.comment.commentId,
                  opUserId: widget.opUserId,
                ),
              ),
            ),
            child: Text(
                'Open ${widget.comment.childCount} reply${widget.comment.childCount == 1 ? '' : 's'}'),
          ),
        if (widget.comment.childCount > 0 && !_isCollapsed)
          Container(
            margin: const EdgeInsets.only(left: 1),
            padding: const EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: widget.comment.children!
                  .asMap()
                  .entries
                  .map((item) => EntryComment(
                        item.value,
                        (newValue) {
                          var newChildren = [...widget.comment.children!];
                          newChildren[item.key] = newValue;
                          widget.onUpdate(widget.comment.copyWith(
                            childCount: widget.comment.childCount + 1,
                            children: newChildren,
                          ));
                        },
                        opUserId: widget.opUserId,
                        onClick: widget.onClick,
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }
}
