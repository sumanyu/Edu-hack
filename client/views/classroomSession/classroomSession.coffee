Template.chatBox.helpers
  areMessagesReady: ->
    ClassroomSession.findOne({_id: Session.get('classroomSessionId')}) || false

  messages: ->
    # fetch all chat messages
    ClassroomSession.findOne({_id: Session.get('classroomSessionId')}, {fields: {messages: 1}}).messages

  chatPartner: ->
    getChatPartner().name

getCurrentClassroomSession = ->
  ClassroomSession.findOne({_id: Session.get('classroomSessionId')}, {fields: {tutor: 1, tutee: 1}})

getChatPartner = ->
  currentUser = Meteor.user()
  currentSession = getCurrentClassroomSession()
  tutor = currentSession.tutor
  tutee = currentSession.tutee

  if currentUser._id is tutor.id then tutee else tutor  

sendMessage = ->
  message = $(".chat-message").val()

  # Prevent empty messages
  if message.length > 0
    totalMessage = 
      message: message
      user:
        id: Meteor.userId()
        name: Meteor.user().profile.name

    console.log totalMessage

    # Push messages
    ClassroomSession.update {_id: Session.get('classroomSessionId')}, {$push: {messages: totalMessage}}

    $(".chat-message").val ""

Template.chatBox.rendered = ->
  console.log "Chatbox re-rendering..."
  focusText($('.chat-message'))

  # Auto-scroll chat
  $('.chatMessages').scrollTop($('.chatMessages')[0].scrollHeight)

Template.chatBox.events 
  "keydown .chat-message": (e, s) ->
    if e.keyCode is 13
      e.preventDefault()
      console.log "entering?"
      sendMessage()

Template.classroomSessionSidebar.helpers
  whiteboardIsSelected: ->
    Session.get('whiteboardIsSelected?')

  fileIsSelected: ->
    Session.get('fileIsSelected?')

  wolframIsSelected: ->
    Session.get('wolframIsSelected?')

Template.classroomSessionPage.helpers
  whiteboardIsSelected: ->
    Session.get('whiteboardIsSelected?')

  fileIsSelected: ->
    Session.get('fileIsSelected?')

  wolframIsSelected: ->
    Session.get('wolframIsSelected?')

Template.classroomSessionSidebar.events 
  "click .whiteboard-button": (e, s) ->
    Session.set('whiteboardIsSelected?', true)
    Session.set('fileIsSelected?', false)
    Session.set('wolframIsSelected?', false)

  "click .file-button": (e, s) ->
    Session.set('whiteboardIsSelected?', false)
    Session.set('fileIsSelected?', true)
    Session.set('wolframIsSelected?', false)

  "click .wolfram-button": (e, s) ->
    Session.set('whiteboardIsSelected?', false)
    Session.set('fileIsSelected?', false)
    Session.set('wolframIsSelected?', true)

  "click .end-session": (e, s) ->
    Session.set('foundTutor?', false)
    Session.set('askingQuestion?', false)

    Meteor.call 'endClassroomSession', Session.get("classroomSessionId"), (err, result) ->
      console.log "Calling end classroom session"

      if err
        console.log err
      else
        Router.go('/dashboard')

Template.whiteBoard.rendered = ->
  # Ensures whiteboard layout has loaded before executing Deps.autorun
  Session.set("hasWhiteboardLoaded?", true)

Template.whiteBoard.events
  'click .draw': (e, s) ->
    pad.startDrawMode()

  'click .erase': (e, s) ->
    pad.startEraseMode()

  'click .clear-blackboard': (e, s) ->
    pad.wipe true     

  'click .start-audio': (e, s) ->
    # Send user's id for now
    # ClassroomStream.emit "audioRequest:#{getChatPartner().id}", Session.get("classroomSessionId")
    
    # For data connections
    # conn = peer.connect("#{getChatPartner.id}")

    # For calls
    navigator.getUserMedia {audio: true}, ((mediaStream) ->
      console.log "Local media stream"
      console.log mediaStream

      call = peer.call("#{getChatPartner.id}", mediaStream)

      call.on 'stream', (remoteStream) ->
        console.log "Remote stream"
        console.log remoteStream
        # Play it locally in the browser

      ), (err) -> console.log "Failed to get local streams", err

pad = undefined
remotePad = undefined

Meteor.startup ->
  Deps.autorun ->
    if Session.get("hasWhiteboardLoaded?")
      if pad
        pad.close()
        remotePad.close()

      # Hot code bypasses `hasWhiteboardLoaded?`
      if $('canvas').length > 0
        user = Meteor.user()?._id || "Anonymous"

        classroomSessionId = Session.get("classroomSessionId")
        pad = new Pad($('canvas'), classroomSessionId, user)
        remotePad = new RemotePad(classroomSessionId, pad)
