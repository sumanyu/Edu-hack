Template.questionTileLeft.helpers
  getSkillName: (skillId) ->
    skill = Skills.findOne(
      {_id: skillId}
    )

    if skill
      return skill.name

    # temporary hack to display fixture tags property
    else
      return skillId