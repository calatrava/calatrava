package com.calatrava.bridge;

import java.lang.annotation.Annotation;

public interface Registration
{
  void install(Annotation annotation, Class<?> toRegister);
}