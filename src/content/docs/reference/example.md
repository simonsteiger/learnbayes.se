---
title: Example Reference
description: A reference page in my new Starlight docs site.
draft: true
---

```math
P(A \vert B)={\frac {P(B \vert A) P(A)}{P(B)}}
```

<div class="max-w-xl mx-auto mt-10">
  <Tabs >
    <TabItem label="R" icon="seti:R">
      <Code code="a <- 1:9" lang="r" mark={["1:9"]} />
    </TabItem>

    <TabItem label="Python" icon="seti:python">
      <Code code="a = range(1, 10)" lang="python" mark={["1, 10"]} />
    </TabItem>

    <TabItem label="Julia" icon="seti:julia">
      <Code code="# ??" lang="julia" />
    </TabItem>

    <TabItem label="STATA">
      <Code code="# ??" lang="stata" />
    </TabItem>

    <TabItem label="SAS">
      <Code code="# ??" lang="sas" />
    </TabItem>
  </Tabs>
</div>

Reference pages are ideal for outlining how things work in terse and clear terms.
Less concerned with telling a story or addressing a specific use case, they should give a comprehensive outline of what you're documenting.

## Further reading

- Read [about reference](https://diataxis.fr/reference/) in the Diátaxis framework
