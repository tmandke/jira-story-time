window.JiraStoryTime = window.JiraStoryTime || {}
window.JiraStoryTime.DragController = {
  handleDragStart: function (e) {
    this.style.opacity = '0.4';  // this / e.target is the source node.
    e.dataTransfer.setData("storyId", $(e.target).closest('.story')[0].getAttribute('id'));
  },

  handleDragOver: function (e) {
    if (e.preventDefault) {
      e.preventDefault(); // Necessary. Allows us to drop.
    }
    return false;
  },

  handleDragEnter: function (e) {
    // this / e.target is the current hover target.
    this.classList.add('over');
    $(this).find('.story_board_row_drop_mask').show();

  },

  handleDragLeave: function (e) {
    e.stopPropagation();
    e.preventDefault();
    $(this.parentElement).removeClass('over');
    $(this).hide();

  },

  handleDrop: function (e) {
    // this / e.target is current target element.

    if (e.stopPropagation) {
      e.stopPropagation(); // stops the browser from redirecting.
    }
    var newPoints = this.parentElement.getAttribute("data-story-points");
    $("#" + e.dataTransfer.getData("storyId")).trigger('pointsChanged', [newPoints]);
    $(e.target).hide();

    // See the section on the DataTransfer object.


    return false;
  },

  handleDragEnd: function (e) {
    // this/e.target is the source node.
    [].forEach.call(window.JiraStoryTime.DragController.cols, function (col) {
      col.style.opacity = '1';
      col.classList.remove('over');
    });
  },

  setup: function (){
    this.cols = document.querySelectorAll('#story_board .story_board_row');
    _this = this;
    [].forEach.call(this.cols, function(col) {
      col.addEventListener('dragstart', _this.handleDragStart, false);
      col.addEventListener('dragenter', _this.handleDragEnter, false);
      col.addEventListener('dragover', _this.handleDragOver, false);
      $(col).find('.story_board_row_drop_mask')[0].addEventListener('dragleave', _this.handleDragLeave, false);
      $(col).find('.story_board_row_drop_mask')[0].addEventListener('drop', _this.handleDrop, false);
      col.addEventListener('dragend', _this.handleDragEnd, false);

    });
  }


}
