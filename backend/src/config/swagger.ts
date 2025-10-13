import swaggerJsdoc from 'swagger-jsdoc';
import { Options } from 'swagger-jsdoc';

const options: Options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'SemaSync API',
      version: '1.0.0',
      description: 'A comprehensive health tracking API for GLP-1 medication users',
      contact: {
        name: 'SemaSync Team',
        email: 'support@semasync.app'
      },
      license: {
        name: 'MIT',
        url: 'https://opensource.org/licenses/MIT'
      }
    },
    servers: [
      {
        url: process.env.NODE_ENV === 'production' 
          ? 'https://api.semasync.app' 
          : `http://localhost:${process.env.PORT || 8080}`,
        description: process.env.NODE_ENV === 'production' ? 'Production server' : 'Development server'
      }
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT'
        }
      },
      schemas: {
        User: {
          type: 'object',
          properties: {
            _id: {
              type: 'string',
              description: 'User ID'
            },
            email: {
              type: 'string',
              format: 'email',
              description: 'User email address'
            },
            firstName: {
              type: 'string',
              description: 'User first name'
            },
            lastName: {
              type: 'string',
              description: 'User last name'
            },
            dateOfBirth: {
              type: 'string',
              format: 'date',
              description: 'User date of birth'
            },
            gender: {
              type: 'string',
              enum: ['male', 'female', 'other'],
              description: 'User gender'
            },
            height: {
              type: 'number',
              description: 'User height in cm'
            },
            weight: {
              type: 'number',
              description: 'User weight in kg'
            },
            preferredUnits: {
              type: 'object',
              properties: {
                weight: {
                  type: 'string',
                  enum: ['kg', 'lbs']
                },
                height: {
                  type: 'string',
                  enum: ['cm', 'ft']
                },
                distance: {
                  type: 'string',
                  enum: ['km', 'miles']
                }
              }
            },
            glp1Journey: {
              type: 'object',
              properties: {
                medication: {
                  type: 'string',
                  enum: ['Zepbound®', 'Mounjaro®', 'Ozempic®', 'Wegovy®', 'Trulicity®', 'Compounded Semaglutide', 'Compounded Tirzepatide']
                },
                startingDose: {
                  type: 'string',
                  enum: ['0.25mg', '0.5mg', '1.0mg', '1.7mg', '2.4mg']
                },
                frequency: {
                  type: 'string',
                  enum: ['Every day', 'Every 7 days (most common)', 'Every 14 days', 'Custom', 'Not sure, still figuring it out']
                },
                injectionDays: {
                  type: 'array',
                  items: {
                    type: 'string',
                    enum: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
                  }
                },
                startDate: {
                  type: 'string',
                  format: 'date'
                },
                currentDose: {
                  type: 'string'
                },
                isActive: {
                  type: 'boolean'
                }
              }
            },
            motivation: {
              type: 'string',
              description: 'User motivation for weight loss'
            },
            concerns: {
              type: 'array',
              items: {
                type: 'string',
                enum: ['Nausea', 'Fatigue', 'Hair Loss', 'Muscle Loss', 'Injection Anxiety', 'Loose Skin']
              }
            },
            goals: {
              type: 'object',
              properties: {
                targetWeight: {
                  type: 'number'
                },
                targetDate: {
                  type: 'string',
                  format: 'date'
                },
                primaryGoal: {
                  type: 'string'
                },
                secondaryGoals: {
                  type: 'array',
                  items: {
                    type: 'string',
                    enum: ['Improved energy', 'Better sleep', 'Increased strength', 'Reduced inflammation', 'Better mood', 'Improved confidence']
                  }
                }
              }
            },
            isEmailVerified: {
              type: 'boolean'
            },
            isPhoneVerified: {
              type: 'boolean'
            },
            accountStatus: {
              type: 'string',
              enum: ['active', 'suspended', 'deleted']
            },
            lastLogin: {
              type: 'string',
              format: 'date-time'
            },
            createdAt: {
              type: 'string',
              format: 'date-time'
            },
            updatedAt: {
              type: 'string',
              format: 'date-time'
            }
          }
        },
        RegisterRequest: {
          type: 'object',
          required: ['email', 'password', 'firstName', 'lastName', 'dateOfBirth', 'gender', 'height', 'weight', 'glp1Journey', 'motivation'],
          properties: {
            email: {
              type: 'string',
              format: 'email'
            },
            password: {
              type: 'string',
              minLength: 6
            },
            firstName: {
              type: 'string',
              maxLength: 50
            },
            lastName: {
              type: 'string',
              maxLength: 50
            },
            dateOfBirth: {
              type: 'string',
              format: 'date'
            },
            gender: {
              type: 'string',
              enum: ['male', 'female', 'other']
            },
            height: {
              type: 'number',
              minimum: 50,
              maximum: 300
            },
            weight: {
              type: 'number',
              minimum: 20,
              maximum: 500
            },
            preferredUnits: {
              type: 'object',
              properties: {
                weight: {
                  type: 'string',
                  enum: ['kg', 'lbs'],
                  default: 'lbs'
                },
                height: {
                  type: 'string',
                  enum: ['cm', 'ft'],
                  default: 'ft'
                },
                distance: {
                  type: 'string',
                  enum: ['km', 'miles'],
                  default: 'miles'
                }
              }
            },
            glp1Journey: {
              type: 'object',
              required: ['medication', 'startingDose', 'frequency'],
              properties: {
                medication: {
                  type: 'string',
                  enum: ['Zepbound®', 'Mounjaro®', 'Ozempic®', 'Wegovy®', 'Trulicity®', 'Compounded Semaglutide', 'Compounded Tirzepatide']
                },
                startingDose: {
                  type: 'string',
                  enum: ['0.25mg', '0.5mg', '1.0mg', '1.7mg', '2.4mg']
                },
                frequency: {
                  type: 'string',
                  enum: ['Every day', 'Every 7 days (most common)', 'Every 14 days', 'Custom', 'Not sure, still figuring it out']
                },
                injectionDays: {
                  type: 'array',
                  items: {
                    type: 'string',
                    enum: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
                  }
                },
                startDate: {
                  type: 'string',
                  format: 'date'
                }
              }
            },
            motivation: {
              type: 'string',
              enum: [
                'I want to feel more confident in my own skin.',
                'I\'m just ready for a fresh start.',
                'I want to boost my energy and strength.',
                'To improve my health and manage PCOS.',
                'I want to show up for the people I love.',
                'I have a special event or milestone coming up.',
                'To feel good wearing the clothes I love again.'
              ]
            },
            concerns: {
              type: 'array',
              items: {
                type: 'string',
                enum: ['Nausea', 'Fatigue', 'Hair Loss', 'Muscle Loss', 'Injection Anxiety', 'Loose Skin']
              }
            },
            goals: {
              type: 'object',
              properties: {
                targetWeight: {
                  type: 'number',
                  minimum: 20,
                  maximum: 500
                },
                targetDate: {
                  type: 'string',
                  format: 'date'
                },
                primaryGoal: {
                  type: 'string'
                },
                secondaryGoals: {
                  type: 'array',
                  items: {
                    type: 'string',
                    enum: ['Improved energy', 'Better sleep', 'Increased strength', 'Reduced inflammation', 'Better mood', 'Improved confidence']
                  }
                }
              }
            }
          }
        },
        LoginRequest: {
          type: 'object',
          required: ['email', 'password'],
          properties: {
            email: {
              type: 'string',
              format: 'email'
            },
            password: {
              type: 'string'
            }
          }
        },
        RefreshTokenRequest: {
          type: 'object',
          required: ['refreshToken'],
          properties: {
            refreshToken: {
              type: 'string'
            }
          }
        },
        ForgotPasswordRequest: {
          type: 'object',
          required: ['email'],
          properties: {
            email: {
              type: 'string',
              format: 'email'
            }
          }
        },
        ResetPasswordRequest: {
          type: 'object',
          required: ['token', 'newPassword'],
          properties: {
            token: {
              type: 'string'
            },
            newPassword: {
              type: 'string',
              minLength: 6
            }
          }
        },
        ChangePasswordRequest: {
          type: 'object',
          required: ['currentPassword', 'newPassword'],
          properties: {
            currentPassword: {
              type: 'string'
            },
            newPassword: {
              type: 'string',
              minLength: 6
            }
          }
        },
        VerifyEmailRequest: {
          type: 'object',
          required: ['token'],
          properties: {
            token: {
              type: 'string'
            }
          }
        },
        ApiResponse: {
          type: 'object',
          properties: {
            success: {
              type: 'boolean'
            },
            message: {
              type: 'string'
            },
            data: {
              type: 'object'
            }
          }
        },
        AuthResponse: {
          type: 'object',
          properties: {
            success: {
              type: 'boolean'
            },
            message: {
              type: 'string'
            },
            data: {
              type: 'object',
              properties: {
                user: {
                  $ref: '#/components/schemas/User'
                },
                tokens: {
                  type: 'object',
                  properties: {
                    accessToken: {
                      type: 'string'
                    },
                    refreshToken: {
                      type: 'string'
                    }
                  }
                }
              }
            }
          }
        },
        ValidationError: {
          type: 'object',
          properties: {
            success: {
              type: 'boolean',
              example: false
            },
            message: {
              type: 'string',
              example: 'Validation failed'
            },
            errors: {
              type: 'array',
              items: {
                type: 'object',
                properties: {
                  type: {
                    type: 'string'
                  },
                  value: {
                    type: 'string'
                  },
                  msg: {
                    type: 'string'
                  },
                  path: {
                    type: 'string'
                  },
                  location: {
                    type: 'string'
                  }
                }
              }
            }
          }
        }
      }
    },
    security: [
      {
        bearerAuth: []
      }
    ]
  },
  apis: ['./src/routes/*.ts', './src/index.ts']
};

export const swaggerSpec = swaggerJsdoc(options);
