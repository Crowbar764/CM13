import { useBackend, useLocalState } from '../backend';
import { Button, Stack, Flex, Section, Box, Tabs, Slider, LabeledList } from '../components';
import { Window } from '../layouts';

export const TechMemories = (props, context) => {
  const { act, data } = useBackend(context);
  const [tab, setTab] = useLocalState(context, 'tab', 1);
  if (data.stats_dynamic) {
    if (data.stats) {
      if (data.original_stats) data.stats = data.original_stats;
      else data.original_stats = data.stats;

      data.stats = data.stats.concat(data.stats_dynamic || []);
    } else {
      data.original_stats = [];
      data.stats = data.stats_dynamic;
    }
  }

  const clues1 = [
    {
      location: "the Hallway Stern"
    },
    {
      location: "the Hallway Aft"
    }
  ];

  const clues2 = [
    {
      itemID: "M24D",
      location: "the Hallway Stern"
    },
    {
      itemID: "M24D",
      location: "the Hallway Aft"
    }
  ];

  const clues = [
    {
      color: "Grey",
      itemID: "ABC2",
      location: "the Hallway Stern"
    },
    {
      color: "Red",
      itemID: "EFG2",
      location: "the Hallway Aft"
    },
    {
      color: "White",
      itemID: "EFG2",
      location: "the Hallway Aft"
    },
    {
      color: "Green",
      itemID: "EFG2",
      location: "the Hallway Aft"
    },
    {
      color: "Blue",
      itemID: "EFG2",
      location: "the Hallway Aft"
    }
  ];

  const clues3 = [
    {
      color: "Grey",
      itemID: "ABC2",
      key: "HHFH455",
      location: "the Hallway Stern"
    },
    {
      color: "Red",
      itemID: "EFG2",
      key: "3845Ff55",
      location: "the Hallway Aft"
    },
    {
      color: "White",
      itemID: "EFG2",
      key: "3845Ff55",
      location: "the Hallway Aft"
    },
    {
      color: "Green",
      itemID: "EFG2",
      key: "3845Ff55",
      location: "the Hallway Aft"
    },
    {
      color: "Blue",
      itemID: "EFG2",
      key: "3845Ff55",
      location: "the Hallway Aft"
    }
  ];

  const {
    total_points,
    can_buy,
    unlocked,
    theme,
    cost,
    name,
    desc,
    extra_buttons,
    extra_sliders,
    stats,
  } = data;

  return (
    <Window
      width={650}
      height={700}
      theme={theme}
    >
      <Window.Content scrollable>
        <Section title="Tech Points"
          buttons={(
            <Button
              content="Open Tech Tree"
              onClick={() => act('open_techweb')}
            />
          )}
        >
        <Box fontSize="16px">{100 + " (+0.05 / min)"}</Box>
      </Section>

      <Objectives/>

      <Section title="Clues">
      <Tabs fluid>
          <Tabs.Tab
            selected={tab === 1}
            onClick={() => setTab(1)}>
            Reports (12)
          </Tabs.Tab>
          <Tabs.Tab
            selected={tab === 2}
            onClick={() => setTab(2)}>
            Folders ({clues.length})
          </Tabs.Tab>
          <Tabs.Tab
            selected={tab === 3}
            onClick={() => setTab(3)}>
            Manuals (3)
          </Tabs.Tab>
          <Tabs.Tab
            selected={tab === 4}
            onClick={() => setTab(4)}>
            Disks (3)
          </Tabs.Tab>
          <Tabs.Tab
            selected={tab === 5}
            onClick={() => setTab(5)}>
            Terminals (3)
          </Tabs.Tab>
          <Tabs.Tab
            selected={tab === 6}
            onClick={() => setTab(6)}>
            Items (3)
          </Tabs.Tab>
          <Tabs.Tab
            selected={tab === 7}
            onClick={() => setTab(7)}>
            Other (3)
          </Tabs.Tab>
        </Tabs>

        {tab === 1 && (
          <CluesAdvanced
          itemName="Progress report"
          clues={clues1}>
          </CluesAdvanced>
        )}
        {tab === 2 && (
          <CluesAdvanced
          itemName="folder"
          clues={clues}>
          </CluesAdvanced>

        )}
        {tab === 3 && (
          <CluesAdvanced
            itemName="Technical manual"
            clues={clues2}>
          </CluesAdvanced>
        )}
        {tab === 4 && (
          <CluesAdvanced
            itemName="disk"
            clues={clues3}>
          </CluesAdvanced>
        )}
        </Section>

      </Window.Content>
    </Window>
  );
};

const Objectives = (props, context) => {
  const { data } = useBackend(context);

  const test123 = [
    {
      label: "Documents",
      content_credits: "420pts"
    },
    {
      label: "Data retrieval",
      content_credits: "100pts",
    },
    {
      label: "Item retrieval",
      content_credits: "420pts"
    },
    {
      label: "Analyze chems",
      content_credits: "420pts"
    },
    {
      label: "Colony communications",
      content: "Online",
      content_color: "green",
      content_credits: "(420pts)"
    },
    {
      label: "Colony generators",
      content: "Offline",
      content_color: "red",
    },
    {
      label: "Colony generators",
      content: "20000W. 30000W required",
      content_color: "orange",
      content_credits: "(100pts)",
    },
    {
      label: "Colony generators",
      content: "Online",
      content_color: "green",
      content_credits: "(200pts)",
    },
    {
      label: "Colony power grid",
      content: "5/24 APCs online",
      content_color: "orange",
      content_credits: "(300pts. +5pts / 10 mins)"
    },
    {
      label: "Corpses recovered",
      content_credits: "100pts",
    }
  ];

  return (
    <Section title="Objectives"
    buttons={(
      <Button
        content="Total earned credits: 620"
        backgroundColor="transparent"
        tooltip="1 credit = 0.05 tech points"
        tooltipPosition="bottom-left"
      />
    )}
    >
      <LabeledList>
        {test123.map((page) => {
          return (
            <LabeledList.Item label={page.label}>
              {!!page.content && (
                <Box color={page.content_color} inline mr={1}>{page.content}</Box>
              )}
              {page.content_credits}
            </LabeledList.Item>
          );
        })}
      </LabeledList>

    </Section>
  );
};

const CluesBasic = (props, context) => {
  const { clues, itemName } = props;

  return (
    <Section>
      <Box>{clues}</Box>
    </Section>
  );
};

const CluesAdvanced = (props, context) => {
  const { clues, itemName } = props;

  return (
    <Section>
      <Flex direction="column">
      {clues.map((clue) => {
        return (
          <Flex
            key={0}
            className="candystripe"
            justify="space-between"
            px="1rem"
            py=".5rem"
          >
            <Flex.Item>
              {!!clue.color && (
                <Box inline color={clue.color.toLowerCase()} mr={1}>{clue.color}</Box>
              )}
              {itemName}
              <Box inline ml={1} bold>{clue.itemID}</Box>
              {!!clue.key && (
                <Fragment>
                  {", decryption key is "}
                  <Box inline bold>{clue.key}</Box>
                </Fragment>
              )}
            </Flex.Item>
            <Flex.Item>
              {clue.location}
            </Flex.Item>
          </Flex>
        );
      })}
      </Flex>
    </Section>
  );
};
