# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

class Seeds
  def initialize
    base_seeds!
    run_env_seeds!
  end

  private

  def run_env_seeds!
    seeder = "#{Rails.env}_seeds!"
    if respond_to?(seeder.to_sym, true)
      send(seeder)
    else
      log "Seeds for #{Rails.env} not defined, skipping.", level: :warn
    end
  end

  def base_seeds!
    # Set up user roles
    Role.create!(name: "admin", friendly_name: "Admin")
    Role.create!(name: "coordinator", friendly_name: "Coordinator")
    Role.create!(name: "manager", friendly_name: "Team Member")
    Role.create!(name: "analyst", friendly_name: "Visitor")

    # set up Actor Types with taxonomies ########################################################
    # 1 Countries
    countries = Actortype.create!(
      title: "Country",
      has_members: true,
      is_active: true,
      is_target: true
    )

    # 2 Organisations
    orgs = Actortype.create!(
      title: "Organisation",
      has_members: true,
      is_active: true,
      is_target: true
    )

    # 3 Contacts (external)
    contacts = Actortype.create!(
      title: "Contacts",
      is_active: true
    )

    # 4 Regions
    regions = Actortype.create!(
      title: "Region",
      has_members: true,
      is_active: false,
      is_target: true
    )

    # 5 Groups
    groups = Actortype.create!(
      title: "Group",
      has_members: true,
      is_active: true,
      is_target: true
    )

    # set up Activity Types with taxonomies ########################################################
    # 1 Expressions
    expressions = Measuretype.create!(
      title: "Expression",
      has_target: true,
      has_parent: true
      # has_indicators: true,
    )

    # 2 Events
    events = Measuretype.create!(
      title: "Event",
      has_target: true,
      has_parent: true
    )

    # 3 Outreach plans
    outreachplans = Measuretype.create!(
      title: "Outreach plan",
      has_target: true,
      has_parent: true
    )

    # 4 Advocacy plans
    advocacyplans = Measuretype.create!(
      title: "Advocacy plan",
      has_target: true,
      has_parent: true
    )

    # 5 Tasks (outreach, advocacy?)
    tasks = Measuretype.create!(
      title: "Task",
      has_target: true,
      has_parent: true
    )

    # 6 Interactions
    interactions = Measuretype.create!(
      title: "Interaction",
      has_target: true,
      has_parent: true
    )

    # set up Resource Types ########################################################
    Resourcetype.create!(
      title: "Reference"
    )
    Resourcetype.create!(
      title: "Web"
    )
    Resourcetype.create!(
      title: "Documents"
    )

    # Set up taxonomies ########################################################
    # 1 Country status
    countrystatus = Taxonomy.create!(
      title: "Country status",
      allow_multiple: false
    )
    ActortypeTaxonomy.create!(
      taxonomy: countrystatus, # 1
      actortype: countries # 1
    )
    # 2 Organisation sector
    orgsector = Taxonomy.create!(
      title: "Sector",
      allow_multiple: false
    )
    ActortypeTaxonomy.create!(
      taxonomy: orgsector, # 2
      actortype: orgs # 2
    )
    # 3 Contact type aka "role"
    contacttype = Taxonomy.create!(
      title: "Role",
      allow_multiple: true
    )
    ActortypeTaxonomy.create!(
      taxonomy: contacttype, # 3
      actortype: contacts # 3
    )
    # 4 Type of region
    regiontype = Taxonomy.create!(
      title: "Region type",
      allow_multiple: true
    )
    ActortypeTaxonomy.create!(
      taxonomy: regiontype, # 4
      actortype: regions # 4
    )
    # 5 type of group
    grouptype = Taxonomy.create!(
      title: "Type of group",
      allow_multiple: false
    )
    ActortypeTaxonomy.create!(
      taxonomy: grouptype, # 5
      actortype: groups # 5
    )
    # 6 level of support
    _supportlevel = Taxonomy.create!(
      title: "Level of support",
      allow_multiple: false
    )
    # MeasuretypeTaxonomy.create!(
    #   taxonomy: supportlevel, #6
    #   measuretype: expressions #1
    # )
    # no longer applied see issue #43

    # 7 type of expression
    expressiontype = Taxonomy.create!(
      title: "Form of expression",
      allow_multiple: false
    )
    MeasuretypeTaxonomy.create!(
      taxonomy: expressiontype, # 7
      measuretype: expressions # 1
    )
    # 8 tags (buzzwords)
    tags = Taxonomy.create!(
      title: "Tags",
      allow_multiple: true
    )
    MeasuretypeTaxonomy.create!(
      taxonomy: tags, # 8
      measuretype: expressions # 1
    )
    # 9 type of event
    eventtype = Taxonomy.create!(
      title: "Type of event",
      allow_multiple: false
    )
    MeasuretypeTaxonomy.create!(
      taxonomy: eventtype, # 9
      measuretype: events # 2
    )
    # 10 priority of plan
    priority = Taxonomy.create!(
      title: "Priority",
      allow_multiple: false
    )
    MeasuretypeTaxonomy.create!(
      taxonomy: priority, # 10
      measuretype: outreachplans # 3
    )
    MeasuretypeTaxonomy.create!(
      taxonomy: priority, # 10
      measuretype: advocacyplans # 4
    )
    MeasuretypeTaxonomy.create!(
      taxonomy: priority, # 10
      measuretype: tasks # 5
    )
    # 11 task status
    status = Taxonomy.create!(
      title: "Status",
      allow_multiple: false
    )
    MeasuretypeTaxonomy.create!(
      taxonomy: status, # 11
      measuretype: tasks # 5
    )
    # 12 interaction type
    interactiontype = Taxonomy.create!(
      title: "Type of interaction",
      allow_multiple: false
    )
    MeasuretypeTaxonomy.create!(
      taxonomy: interactiontype, # 12
      measuretype: interactions # 6
    )
    # 13 authority
    authority = Taxonomy.create!(
      title: "Authority",
      allow_multiple: false
    )
    MeasuretypeTaxonomy.create!(
      taxonomy: authority, # 13
      measuretype: expressions # 1
    )

    # Set up categories ########################################################
    # Convention status
    # convstatus.categories.create!(title: "Signed")

    # country status taxonomy #1
    countrystatus.categories.create!(title: "1 - Champion")
    countrystatus.categories.create!(title: "2 - Like-Minded")
    countrystatus.categories.create!(title: "3 - Positive")
    countrystatus.categories.create!(title: "4 - Skeptical")
    countrystatus.categories.create!(title: "5 - Opponent")

    # Org sector taxonomy #2
    orgsector.categories.create!(title: "Civil society")
    orgsector.categories.create!(title: "Private sector")
    orgsector.categories.create!(title: "Science & research")
    orgsector.categories.create!(title: "Public sector")
    orgsector.categories.create!(title: "Intergovernmental organisations")

    # Contact type taxonomy #3
    contacttype.categories.create!(title: "Chief Administrative Secretary")
    contacttype.categories.create!(title: "Acting Director General")
    contacttype.categories.create!(title: "Counsellor")
    contacttype.categories.create!(title: "Secretary of State")
    contacttype.categories.create!(title: "Minister")
    contacttype.categories.create!(title: "Director")
    contacttype.categories.create!(title: "Government Representative")
    contacttype.categories.create!(title: "Deputy Permanent Representative")
    contacttype.categories.create!(title: "Deputy Director")
    contacttype.categories.create!(title: "Corporate Representative")
    contacttype.categories.create!(title: "First Secretary")
    contacttype.categories.create!(title: "Ambassador")
    contacttype.categories.create!(title: "Permanent Representative")
    contacttype.categories.create!(title: "Academics")
    contacttype.categories.create!(title: "Head of Delegation INC")
    contacttype.categories.create!(title: "Deputy Director General")
    contacttype.categories.create!(title: "INC Focal Point")

    # Region type taxonomy #4
    regiontype.categories.create!(title: "Subregion")
    regiontype.categories.create!(title: "Region")

    # Group type taxonomy #5
    grouptype.categories.create!(title: "Intergovernmental")
    grouptype.categories.create!(title: "Mixed")

    # Expression type taxonomy #7
    expressiontype.categories.create!(title: "Plenary statement")
    expressiontype.categories.create!(title: "Position paper")
    expressiontype.categories.create!(title: "Bilateral")
    expressiontype.categories.create!(title: "EU - NGO meeting")
    expressiontype.categories.create!(title: "Forum Communiqué")
    expressiontype.categories.create!(title: " Breakout group")

    # Event type taxonomy #9
    eventtype.categories.create!(title: "State-ledevent")
    eventtype.categories.create!(title: "Hybrid")
    eventtype.categories.create!(title: "UNEP-led event")
    eventtype.categories.create!(title: "WWF-led event")
    eventtype.categories.create!(title: "Digital")

    # Priority taxonomy #10
    priority.categories.create!(title: "1 - High priority")
    priority.categories.create!(title: "2 - Normal priority")
    priority.categories.create!(title: "3 - Low priority")

    # Status taxonomy #11
    status.categories.create!(title: "1 - In preparation")
    status.categories.create!(title: "2 - In progress")
    status.categories.create!(title: "3 - Completed")

    # Interaction type taxonomy #12
    interactiontype.categories.create!(title: "In person")
    interactiontype.categories.create!(title: "Phone")
    interactiontype.categories.create!(title: "Email")
    interactiontype.categories.create!(title: "Online call")
    interactiontype.categories.create!(title: "Letter")
    interactiontype.categories.create!(title: "Online meeting chat ")
    interactiontype.categories.create!(title: "Whatsapp Chat")

    # Authority taxonomy #13
    authority.categories.create!(title: "1 - Official")
    authority.categories.create!(title: "2 - Inofficial")
    authority.categories.create!(title: "3 - Own assessment")
    authority.categories.create!(title: "4 Third party assessment")
  end

  def development_seeds!
    return unless User.count.zero?
  end

  def log(msg, level: :info)
    Rails.logger.public_send(level, msg)
  end
end

Seeds.new
