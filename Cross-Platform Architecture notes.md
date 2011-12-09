# Approaches for supporting multiple native platforms

## the *All Native* approach

In this appoach the same functionality is implemented from scratch on each platform natively. Because each platform uses a different language, there is no opportunity to reuse common code, and it must be re-implemented.

## the *Write Once Run Anywhere* approach

A tool such as Kony or Titanium allows you to implement your application once, with the tool generating native applications from the common implementation. Some tools use an embedded interpreter and run your code in that interpretter, while others compile your shared code into a native language which is executed directly on the target platform. This approach can allow you to quite cheaply support multiple platforms natively. One drawback is that it can be hard to generate a polished experience. 

## the *Cross-platform Core* approach

Similar to some WORA solution, you implement your core business logic in a common language such as JavaScript. But rather than using a tool to generate the native app UI you write it by hand for each platform. At runtime your common core runs in an embedded interpreter, driving the native UI components inside your app using a bridge. One nice side-effect of this approach is it leads to a nicely layered architecture, with non-presentation logic clearly seperated from the presentation code. This makes it a lot easier to get the non-presentation logic under test coverage.

## the Mobile Web approach

#When to use what
- If most of your application code will be presentation level and you want a really polished UX, you are probably best of going All Native. 
- If you need to rapidly create a native app on multiple platforms and high UI polish isn't important to you then you are probably best going with a WORA solution. 
- If your application will contain a significant amount of business logic (as opposed to presentation logic) and you want a very native feel then a Cross-Platform Core may be the best approach.
- If you don't want to be on the app store, and are concerned about platform lockin then you might want to consider Mobile Web.
