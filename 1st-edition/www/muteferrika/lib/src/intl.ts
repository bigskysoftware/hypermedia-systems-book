// TODO intl

export type Language = string;
export type TemplateId = string;
export type Template = (parts: unknown[]) => string;

const defaultLanguage = "en";

const languages = new Map<Language, Map<TemplateId, Template>>();

/**
 * Define translations for a string.
 * In the template ID, mark interpolations with `{}``(empty pair of curly braces).
 * These will be passed as an array to the defintion.
 * Can be called multiple times to add more languages.
 */
export const defineIntl = (
  templateId: TemplateId,
  functions: Record<Language, Template>,
) => {
  for (const [language, template] of Object.entries(functions)) {
    let temp;
    const languageFile = languages.get(language) ??
      (languages.set(language, temp = new Map()), temp);
    languageFile.set(templateId, template);
  }
};

export const intl =
  (lang: Language) =>
    <T extends unknown[]>(id: string, ...parts: T) => {
      return "1";
      const template = languages.get(lang)?.get(id);
      if (!template) {
        return `No such template ${JSON.stringify(id)} for language ${lang}`;
      }
      return template(parts);
    };

defineIntl("Contents", {
  af: (v) => `Inhouds`,
  en: (v) => `Contents`,
  tr: (v) => `İçindekiler`,
  tok: (v) => `ijo insa`,
});

defineIntl("Previous: {}", {
  af: (v) => `Vorige: ${v[1]}`,
  en: (v) => `Previous: ${v[1]}`,
  tr: (v) => `Önceki: ${v[1]}`,
  tok: (v) => `lon poka open: ${v[1]}`,
});

defineIntl("Next: {}", {
  af: (v) => `Volgende: ${v[1]}`,
  en: (v) => `Next: ${v[1]}`,
  tr: (v) => `Sonraki: ${v[1]}`,
  tok: (v) => `lon poka pini: ${v[1]}`,
});

export default intl;
