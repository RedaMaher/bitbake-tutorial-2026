addhandler tutorial_event_observer
tutorial_event_observer[eventmask] = "bb.event.RecipeParsed bb.event.BuildStarted bb.event.BuildCompleted bb.build.TaskStarted bb.build.TaskSucceeded bb.build.TaskFailed"

python tutorial_event_observer() {
    name = bb.event.getName(e)
    if isinstance(e, bb.event.RecipeParsed):
        if d.getVar("PN") == "event-demo":
            bb.plain("CH18 EVENT RecipeParsed pn=event-demo")
    elif isinstance(e, (bb.event.BuildStarted, bb.event.BuildCompleted)):
        bb.plain("CH18 EVENT %s" % name)
    elif getattr(e, "pn", "") in ("event-demo", "event-peer"):
        bb.plain("CH18 EVENT %s pn=%s task=%s" % (name, e.pn, e.taskname))
}
