import { useBackend, useLocalState } from '../backend';
import { Button, Flex, Section, Box, Tabs, Fragment, LabeledList } from '../components';
import { Window } from '../layouts';

export const TechMemories = (props, context) => {
  const { act, data } = useBackend(context);
  const [clueCategory, setClueCategory] = useLocalState(context, 'clueCategory', 0);
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

  const {
    tech_points,
    theme,
    clue_categories,
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
          <Box fontSize="16px">{tech_points + " (+" + data.passive_tech_points + " / min)"}</Box>
        </Section>

        <Objectives />

        <Section title="Clues">
          <Tabs fluid>
            {clue_categories.map((clue_category, i) => {
              return (
                <Tabs.Tab
                  key={i}
                  color="blue"
                  selected={i === clueCategory}
                  icon={clue_category.icon}
                  onClick={() => setClueCategory(i)}
                >
                  {clue_category.name}
                  {!!clue_category.clues.length && (
                    " (" + clue_category.clues.length + ")"
                  )}
                </Tabs.Tab>
              );
            })}
          </Tabs>

          <CluesAdvanced
            clues={clue_categories[clueCategory].clues}
          />
        </Section>

      </Window.Content>
    </Window>
  );
};

const CluesAdvanced = (props, context) => {
  const { clues } = props;

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
                  <Box inline preserveWhitespace color={clue.color_name}>
                    {clue.color + " "}
                  </Box>
                )}
                {clue.text}
                {!!clue.itemID && (
                  <Box inline bold preserveWhitespace>
                    {" " + clue.itemID}
                  </Box>
                )}
                {!!clue.key && (
                  <Fragment>
                    {clue.key_text}
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

const Objectives = (props, context) => {
  const { data } = useBackend(context);

  // const test123 = [
  //   {
  //     label: "Documents",
  //     content: "5 / 20",
  //     content_color: "orange",
  //     content_credits: "(420pts)",
  //   },
  //   {
  //     label: "Data retrieval",
  //     content_credits: "100pts",
  //   },
  //   {
  //     label: "Item retrieval",
  //     content_credits: "420pts",
  //   },
  //   {
  //     label: "Analyze chems",
  //     content: "5 / ∞",
  //     content_credits: "420pts",
  //   },
  //   {
  //     label: "Colony communications",
  //     content: "Online",
  //     content_color: "green",
  //     content_credits: "(420pts)",
  //   },
  //   {
  //     label: "Colony generators",
  //     content: "Offline",
  //     content_color: "red",
  //   },
  //   {
  //     label: "Colony generators",
  //     content: "20000W. 30000W required",
  //     content_color: "orange",
  //     content_credits: "(100pts)",
  //   },
  //   {
  //     label: "Colony generators",
  //     content: "Online",
  //     content_color: "green",
  //     content_credits: "(200pts)",
  //   },
  //   {
  //     label: "Colony power grid",
  //     content: "5/24 APCs online",
  //     content_color: "orange",
  //     content_credits: "(300pts. +5pts / 10 mins)",
  //   },
  //   {
  //     label: "Corpses recovered",
  //     content_credits: "100pts",
  //   },
  // ];

  return (
    <Section title="Objectives"
      buttons={(
        <Button
          content={"Total earned credits: " + data.total_tech_points}
          backgroundColor="transparent"
        />
      )}
    >
      <LabeledList>
        {data.objectives.map((page) => {
          return (
            <LabeledList.Item label={page.label} key={0}>
              {!!page.content && (
                <Box color={page.content_color ? page.content_color : "white"} inline preserveWhitespace>
                  {page.content + " "}
                </Box>
              )}
              {page.content_credits}
            </LabeledList.Item>
          );
        })}
      </LabeledList>

    </Section>
  );
};
